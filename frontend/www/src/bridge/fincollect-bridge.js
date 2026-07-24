(function () {
  const SUPABASE_URL = "https://tflsmxmuvrecrewknbvb.supabase.co";
  const SUPABASE_KEY = "sb_publishable_OAx279ocalpzqLVAhhMb-w_WdfkOWUH";
  const SELECTED_CASE_KEY = "lot-selected-case";
  const REALTIME_CHANNEL = "lot-field-collection-live";

  let supabaseClient = null;
  let casesCache = [];
  let realtimeChannel = null;
  let availabilityCache = {};
  let syncTimer = null;

  function loadSupabaseSDK(callback) {
    if (window.supabase || window.Supabase || typeof createClient === "function") {
      callback();
      return;
    }

    const script = document.createElement("script");
    script.src = "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2";
    script.onload = callback;
    script.onerror = () => console.error("[LOT Bridge] Failed to load Supabase SDK.");
    document.head.appendChild(script);
  }

  function createSupabaseClient() {
    if (window.supabase && typeof window.supabase.createClient === "function") {
      return window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
    }
    if (window.Supabase && typeof window.Supabase.createClient === "function") {
      return window.Supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
    }
    if (typeof createClient === "function") {
      return createClient(SUPABASE_URL, SUPABASE_KEY);
    }
    return null;
  }

  function escapeHtml(value) {
    return String(value || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/\"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function toNumber(value) {
    const num = Number(value);
    return Number.isFinite(num) ? num : 0;
  }

  function formatCurrency(value) {
    return new Intl.NumberFormat("en-IN", {
      style: "currency",
      currency: "INR",
      maximumFractionDigits: 0,
    }).format(toNumber(value));
  }

  function formatTimestamp(value) {
    if (!value) return "Just now";
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return "Just now";
    return date.toLocaleString("en-IN", {
      day: "2-digit",
      month: "short",
      hour: "2-digit",
      minute: "2-digit",
    });
  }

  function deriveOutstanding(caseRow) {
    const target = toNumber(caseRow.loan_repay_amount || caseRow.loan_amount);
    const collected = toNumber(caseRow.total_collected_amount);
    if (collected > 0) {
      return Math.max(target - collected, 0);
    }
    return target;
  }

  function deriveEmi(caseRow) {
    const tenure = toNumber(caseRow.tenure);
    const total = toNumber(caseRow.loan_repay_amount || caseRow.loan_amount);
    if (tenure > 0) {
      return total / tenure;
    }
    return total;
  }

  function deriveRisk(caseRow) {
    const dueDays = toNumber(caseRow.due_days);
    if (dueDays >= 180) return "CRITICAL";
    if (dueDays >= 90) return "HIGH";
    if (dueDays >= 30) return "MEDIUM";
    return "LOW";
  }

  function getSelectedCase() {
    try {
      const raw = localStorage.getItem(SELECTED_CASE_KEY);
      return raw ? JSON.parse(raw) : null;
    } catch (error) {
      console.warn("[LOT Bridge] Failed to parse selected case.", error);
      return null;
    }
  }

  function applySelectedCaseGlobals(caseRow) {
    if (!caseRow) return;
    window.currentCaseId = caseRow.id;
    window.currentLoanId = caseRow.id;
    window.currentCustomerId = caseRow.id;
    window.currentBranchId = caseRow.branch_name || caseRow.state_name || null;
    window.currentLoanNo = caseRow.loan_no || null;
    window.currentCaseRow = caseRow;
  }

  function setSelectedCase(caseRow) {
    if (!caseRow) return;
    localStorage.setItem(SELECTED_CASE_KEY, JSON.stringify(caseRow));
    applySelectedCaseGlobals(caseRow);
  }

  function showToast(message, isError) {
    const toast = document.createElement("div");
    toast.style.cssText = [
      "position:fixed",
      "bottom:20px",
      "right:20px",
      `background:${isError ? "#b91c1c" : "#059669"}`,
      "color:#ffffff",
      "padding:12px 20px",
      "border-radius:10px",
      "box-shadow:0 10px 25px rgba(0,0,0,0.2)",
      "z-index:9999",
      "font-family:Inter, sans-serif",
      "font-weight:600",
      "max-width:320px",
    ].join(";");
    toast.innerText = message;
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), 4000);
  }

  async function getCurrentUser() {
    if (!supabaseClient) return null;
    const { data } = await supabaseClient.auth.getUser();
    return data.user || null;
  }

  async function isTableAvailable(tableName) {
    if (availabilityCache[tableName] !== undefined) {
      return availabilityCache[tableName];
    }

    const { error } = await supabaseClient.from(tableName).select("id", { head: true, count: "exact" }).limit(1);
    availabilityCache[tableName] = !(error && error.code === "PGRST205");
    return availabilityCache[tableName];
  }

  function findCaseById(caseId) {
    return casesCache.find((item) => item.id === caseId) || null;
  }

  function navigateToScreen(relativePath) {
    window.location.href = new URL(relativePath, window.location.href).href;
  }

  function updateSyncBadge() {
    const syncBadge = document.querySelector("#system-sync-status, .sync-status-badge");
    if (!syncBadge) return;
    const nowTime = new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", second: "2-digit" });
    syncBadge.innerHTML = `<span class="w-2 h-2 rounded-full bg-emerald-500 animate-ping inline-block mr-1.5"></span> Live Synced (${nowTime})`;
  }

  function bindCaseSelectionEvents() {
    document.addEventListener("click", (event) => {
      const selector = event.target.closest("[data-case-select], [data-case-action]");
      if (!selector) return;

      const caseId = selector.getAttribute("data-case-id") || selector.getAttribute("data-case-select");
      const selectedCase = findCaseById(caseId) || getSelectedCase();
      if (selectedCase) {
        setSelectedCase(selectedCase);
      }

      const action = selector.getAttribute("data-case-action");
      if (!action) return;

      event.preventDefault();
      if (!selectedCase) {
        showToast("Please select a live case first.", true);
        return;
      }

      if (action === "details") navigateToScreen("../customer_details/code.html");
      if (action === "visit") navigateToScreen("../visit_screen/code.html");
      if (action === "payment") navigateToScreen("../payment_screen/code.html");
    });
  }

  function bindAuthForms() {
    const loginForm = document.getElementById("loginForm") || document.querySelector("form");
    const emailInput = document.getElementById("email") || document.querySelector('input[type="email"]');
    const passwordInput = document.getElementById("password") || document.querySelector('input[type="password"]');
    const loginBtn = document.getElementById("loginBtn") || document.querySelector("button[type='submit']");
    if (!loginBtn) return;

    loginBtn.addEventListener("click", async (event) => {
      if (loginForm) event.preventDefault();
      if (!supabaseClient) {
        showToast("Supabase client not initialized.", true);
        return;
      }

      const email = emailInput ? emailInput.value.trim() : "";
      const password = passwordInput ? passwordInput.value : "";
      const originalText = loginBtn.innerHTML;

      loginBtn.disabled = true;
      loginBtn.innerHTML = '<span class="material-symbols-outlined animate-spin">progress_activity</span> Signing in...';

      try {
        const { error } = await supabaseClient.auth.signInWithPassword({ email, password });
        if (error) throw error;
        loginBtn.innerHTML = '<span class="material-symbols-outlined">check_circle</span> Connected';
        showToast("Login successful.");
        setTimeout(() => navigateToScreen("../index.html"), 500);
      } catch (error) {
        showToast(`Login failed: ${error.message}`, true);
        loginBtn.disabled = false;
        loginBtn.innerHTML = originalText;
      }
    });
  }

  function bindSyncForms() {
    const syncBtn = document.querySelector("#trigger-sync-btn, button.sync-now, .sync-btn");
    if (!syncBtn) return;
    syncBtn.addEventListener("click", async (event) => {
      event.preventDefault();
      await bindDashboardMetrics();
      await hydrateSelectedCaseIntoPage();
      showToast("Latest cases pulled from Supabase.");
    });
  }

  function getPaymentReference(mode) {
    if (mode === "UPI") return document.getElementById("payment-ref-upi")?.value?.trim() || null;
    if (mode === "CHEQUE") return document.getElementById("payment-ref-cheque")?.value?.trim() || null;
    if (mode === "NEFT") return document.getElementById("payment-ref-neft")?.value?.trim() || null;
    return null;
  }

  async function bindPaymentForms() {
    const collectPayBtn = document.querySelector("#collect-payment-btn, button.collect-pay, .pay-submit");
    if (!collectPayBtn) return;

    collectPayBtn.addEventListener("click", async (event) => {
      event.preventDefault();
      const selectedCase = getSelectedCase();
      if (!selectedCase) {
        showToast("Select a live case before collecting payment.", true);
        return;
      }

      const user = await getCurrentUser();
      if (!user) {
        showToast("Please log in before recording a payment.", true);
        return;
      }

      if (!(await isTableAvailable("case_payments"))) {
        showToast("Database migration for case payments is not applied yet.", true);
        return;
      }

      const amount = toNumber(document.getElementById("payment-amount")?.value);
      if (amount <= 0) {
        showToast("Enter a payment amount greater than zero.", true);
        return;
      }

      const mode = document.querySelector('input[name="payment_mode"]:checked')?.value || "CASH";
      const reference = getPaymentReference(mode);
      const receiptNumber = `RCP-${Date.now()}`;

      const payload = {
        case_id: selectedCase.id,
        loan_no: selectedCase.loan_no,
        customer_name: selectedCase.customer_name,
        executive_id: user.id,
        executive_name: user.email || "Field Executive",
        branch_name: selectedCase.branch_name || selectedCase.state_name || "Unknown",
        amount_paid: amount,
        payment_mode: mode,
        payment_reference: reference,
        receipt_number: receiptNumber,
        notes: `Collected from frontend on ${new Date().toISOString()}`,
      };

      const { error } = await supabaseClient.from("case_payments").insert(payload);
      if (error) {
        showToast(`Payment save failed: ${error.message}`, true);
        return;
      }

      showToast(`Payment saved. Receipt ${receiptNumber}.`);
      await refreshSelectedCaseFromCloud();
      await loadActivityTimeline();
      await bindDashboardMetrics();
    });
  }

  function mapVisitStatus(rawValue) {
    const value = String(rawValue || "").toLowerCase();
    if (value === "met") return "CUSTOMER_MET";
    if (value === "ptp") return "PARTIAL_PAYMENT_PROMISE";
    if (value === "locked") return "DOOR_LOCKED";
    if (value === "refused") return "REFUSED_TO_PAY";
    if (value === "third_party") return "THIRD_PARTY_MET";
    return "CUSTOMER_MET";
  }

  async function bindVisitForms() {
    const submitVisitBtn = document.querySelector("#submit-visit-btn, button.submit-visit, .visit-submit");
    if (!submitVisitBtn) return;

    submitVisitBtn.addEventListener("click", async (event) => {
      event.preventDefault();
      const selectedCase = getSelectedCase();
      if (!selectedCase) {
        showToast("Select a live case before saving a visit.", true);
        return;
      }

      const user = await getCurrentUser();
      if (!user) {
        showToast("Please log in before saving a visit.", true);
        return;
      }

      if (!(await isTableAvailable("case_visits"))) {
        showToast("Database migration for case visits is not applied yet.", true);
        return;
      }

      const visitStatus = mapVisitStatus(document.getElementById("visit-status")?.value);
      const remarks = document.getElementById("visit-remarks")?.value?.trim() || "Visit recorded from frontend.";
      const promiseDate = document.getElementById("visit-promise-date")?.value || null;
      const expectedAmount = document.getElementById("visit-expected-amount")?.value || null;

      navigator.geolocation.getCurrentPosition(async (position) => {
        const payload = {
          case_id: selectedCase.id,
          loan_no: selectedCase.loan_no,
          customer_name: selectedCase.customer_name,
          executive_id: user.id,
          executive_name: user.email || "Field Executive",
          branch_name: selectedCase.branch_name || selectedCase.state_name || "Unknown",
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          visit_status: visitStatus,
          remarks,
          promise_date: promiseDate,
          expected_amount: expectedAmount ? toNumber(expectedAmount) : null,
          photos_urls: [],
        };

        const { error } = await supabaseClient.from("case_visits").insert(payload);
        if (error) {
          showToast(`Visit save failed: ${error.message}`, true);
          return;
        }

        showToast("Visit recorded successfully.");
        await refreshSelectedCaseFromCloud();
        await loadActivityTimeline();
        await bindDashboardMetrics();
      }, (error) => {
        showToast(`Geolocation failed: ${error.message}`, true);
      });
    });
  }

  function renderLiveCasesUI(cases) {
    const listContainer = document.querySelector("#customer-list-container, .customer-cards-list");
    if (!listContainer) return;

    listContainer.innerHTML = `
      <div class="flex justify-between items-center px-1">
        <h2 class="font-title-lg text-title-lg text-on-surface">Customer Queue</h2>
        <span class="text-label-md font-label-md text-secondary">${cases.length} Total</span>
      </div>
      ${cases.slice(0, 50).map((caseRow) => `
        <div class="customer-card bg-surface-container-lowest p-md rounded-xl shadow-sm border border-outline-variant/40 hover:shadow-md transition-all" data-case-select="${escapeHtml(caseRow.id)}" data-case-id="${escapeHtml(caseRow.id)}">
          <div class="flex justify-between items-start gap-4">
            <div class="min-w-0">
              <span class="dpd-chip bg-error-container text-on-error-container font-bold">${escapeHtml(caseRow.bucket || "Open")}</span>
              <h3 class="font-title-md text-title-md text-on-surface font-bold mt-1 truncate">${escapeHtml(caseRow.customer_name || "Customer")}</h3>
              <p class="text-label-md text-outline">Loan: ${escapeHtml(caseRow.loan_no || "N/A")}</p>
            </div>
            <span class="text-xs font-semibold px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-600">${escapeHtml(caseRow.loan_status || "OPEN")}</span>
          </div>
          <div class="grid grid-cols-2 gap-4 mt-3 py-2 border-y border-outline-variant/30 text-xs">
            <div>
              <p class="text-outline uppercase tracking-wider">Outstanding</p>
              <p class="font-bold text-on-surface">${escapeHtml(formatCurrency(deriveOutstanding(caseRow)))}</p>
            </div>
            <div>
              <p class="text-outline uppercase tracking-wider">Collected</p>
              <p class="font-bold text-on-surface">${escapeHtml(formatCurrency(caseRow.total_collected_amount || 0))}</p>
            </div>
          </div>
          <div class="flex gap-2 mt-3">
            <a href="tel:${escapeHtml(caseRow.mobile_number || "")}" class="flex-1 text-center py-2 bg-surface-container-high text-primary rounded-lg font-bold text-xs">Call</a>
            <button class="flex-1 py-2 bg-surface-container-high text-primary rounded-lg font-bold text-xs" data-case-action="details" data-case-id="${escapeHtml(caseRow.id)}">Details</button>
            <button class="flex-1 py-2 bg-primary text-on-primary rounded-lg font-bold text-xs shadow-sm" data-case-action="visit" data-case-id="${escapeHtml(caseRow.id)}">Visit</button>
          </div>
        </div>
      `).join("")}`;
  }

  function renderAdminTableRows(cases) {
    const tableBody = document.querySelector("tbody");
    if (!tableBody || window.location.pathname.includes("staff")) return;

    tableBody.innerHTML = cases.slice(0, 15).map((caseRow) => `
      <tr class="hover:bg-surface-container-low/50 transition-colors group" data-case-select="${escapeHtml(caseRow.id)}" data-case-id="${escapeHtml(caseRow.id)}">
        <td class="px-lg py-md font-bold text-primary">${escapeHtml(caseRow.loan_no || "N/A")}</td>
        <td class="px-lg py-md font-bold text-on-surface">${escapeHtml(caseRow.customer_name || "N/A")}</td>
        <td class="px-lg py-md font-bold text-emerald-600">${escapeHtml(formatCurrency(deriveOutstanding(caseRow)))}</td>
        <td class="px-lg py-md text-on-surface-variant">${escapeHtml(caseRow.branch_name || caseRow.state_name || "India")}</td>
        <td class="px-lg py-md">
          <span class="px-sm py-1 bg-emerald-100 text-emerald-700 rounded-full text-[10px] font-bold inline-flex items-center gap-xs">
            <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span> ${escapeHtml(caseRow.loan_status || "OPEN")}
          </span>
        </td>
        <td class="px-lg py-md text-on-surface-variant text-xs">${escapeHtml(caseRow.bucket || "Open")}</td>
        <td class="px-lg py-md text-right">
          <button class="material-symbols-outlined text-outline hover:text-primary transition-colors cursor-pointer" data-case-action="payment" data-case-id="${escapeHtml(caseRow.id)}">payments</button>
        </td>
      </tr>
    `).join("");
  }

  async function refreshSelectedCaseFromCloud() {
    const selectedCase = getSelectedCase();
    if (!selectedCase?.id) return;
    const { data } = await supabaseClient.from("cases").select("*").eq("id", selectedCase.id).single();
    if (data) {
      setSelectedCase(data);
    }
  }

  async function fetchCases() {
    const { data, error } = await supabaseClient.from("cases").select("*").order("due_days", { ascending: false }).limit(500);
    if (error) {
      console.warn("[LOT Bridge] Cases fetch failed:", error.message);
      return [];
    }
    return data || [];
  }

  async function bindDashboardMetrics() {
    if (!supabaseClient) return;

    const cases = await fetchCases();
    if (!cases.length) return;

    casesCache = cases;
    const selectedCase = getSelectedCase();
    if (!selectedCase || !findCaseById(selectedCase.id)) {
      setSelectedCase(cases[0]);
    } else {
      setSelectedCase(findCaseById(selectedCase.id));
    }

    document.querySelectorAll(".total-cases-count, #total-loans-counter").forEach((element) => {
      element.innerText = cases.length.toLocaleString();
    });

    const pendingKpi = document.getElementById("kpi-pending-cases");
    if (pendingKpi) pendingKpi.innerText = cases.length.toLocaleString();

    const collectionKpi = document.getElementById("kpi-total-collection");
    if (collectionKpi) {
      const totalCollected = cases.reduce((sum, caseRow) => sum + toNumber(caseRow.total_collected_amount), 0);
      collectionKpi.innerText = formatCurrency(totalCollected);
    }

    const totalVolume = cases.reduce((sum, caseRow) => sum + deriveOutstanding(caseRow), 0);
    document.querySelectorAll(".text-secondary, .text-on-surface-variant").forEach((element) => {
      if (element.innerText && element.innerText.includes("Total") && !element.innerText.includes("STAFF")) {
        element.innerText = `${cases.length} Total Cases`;
      }
    });

    renderLiveCasesUI(cases);
    renderAdminTableRows(cases);
    await hydrateSelectedCaseIntoPage();
    await loadActivityTimeline();

    const { data: users } = await supabaseClient.from("users").select("*");
    if (users?.length) {
      document.querySelectorAll(".total-staff-count").forEach((element) => {
        element.innerText = users.length.toString();
      });
      const execKpi = document.getElementById("kpi-active-executives");
      if (execKpi) execKpi.innerText = `${users.length} / ${users.length}`;
    }

    if (totalVolume >= 0) updateSyncBadge();
  }

  function setTextIfPresent(id, value) {
    const element = document.getElementById(id);
    if (element) element.textContent = value;
  }

  async function hydrateSelectedCaseIntoPage() {
    const caseRow = getSelectedCase();
    if (!caseRow) return;
    applySelectedCaseGlobals(caseRow);

    const outstanding = deriveOutstanding(caseRow);
    const emi = deriveEmi(caseRow);
    const address = caseRow.house_address || caseRow.office_address || `${caseRow.branch_name || "Unknown Branch"}, ${caseRow.state_name || "India"}`;

    setTextIfPresent("selected-case-name", caseRow.customer_name || "Customer");
    setTextIfPresent("selected-case-loan", `Loan ID: ${caseRow.loan_no || "N/A"}`);
    setTextIfPresent("selected-case-status", caseRow.loan_status || "OPEN");
    setTextIfPresent("selected-case-outstanding", formatCurrency(outstanding));
    setTextIfPresent("selected-case-emi", formatCurrency(emi));
    setTextIfPresent("selected-case-location", address);
    setTextIfPresent("selected-case-phone", caseRow.mobile_number || "N/A");
    setTextIfPresent("selected-case-address", address);
    setTextIfPresent("selected-case-tenure", caseRow.tenure ? `${caseRow.tenure} Months` : "N/A");
    setTextIfPresent("selected-case-risk", deriveRisk(caseRow));

    const bucketElement = document.getElementById("selected-case-bucket");
    if (bucketElement) {
      bucketElement.textContent = caseRow.due_days ? `Overdue: ${caseRow.due_days} Days` : `Bucket: ${caseRow.bucket || "Open"}`;
    }

    const callBtn = document.getElementById("selected-case-call-btn");
    if (callBtn && caseRow.mobile_number) {
      callBtn.onclick = () => {
        window.location.href = `tel:${caseRow.mobile_number}`;
      };
    }

    const navBtn = document.getElementById("selected-case-navigate-btn");
    if (navBtn) {
      navBtn.onclick = () => {
        const query = encodeURIComponent(address);
        window.open(`https://www.google.com/maps/search/?api=1&query=${query}`, "_blank");
      };
    }

    const paymentAmount = document.getElementById("payment-amount");
    if (paymentAmount && !paymentAmount.value) {
      paymentAmount.value = String(Math.max(Math.round(Math.min(outstanding, emi)), 1));
    }
  }

  async function loadActivityTimeline() {
    const activityRoot = document.getElementById("selected-case-activity");
    const selectedCase = getSelectedCase();
    if (!activityRoot || !selectedCase) return;

    const timelines = [];
    if (await isTableAvailable("case_visits")) {
      const { data } = await supabaseClient
        .from("case_visits")
        .select("id, visit_status, remarks, executive_name, created_at")
        .eq("case_id", selectedCase.id)
        .order("created_at", { ascending: false })
        .limit(5);
      (data || []).forEach((item) => timelines.push({
        kind: "visit",
        title: item.visit_status.replace(/_/g, " "),
        subtitle: item.remarks,
        actor: item.executive_name || "Field Executive",
        created_at: item.created_at,
      }));
    }

    if (await isTableAvailable("case_payments")) {
      const { data } = await supabaseClient
        .from("case_payments")
        .select("id, amount_paid, payment_mode, executive_name, created_at")
        .eq("case_id", selectedCase.id)
        .order("created_at", { ascending: false })
        .limit(5);
      (data || []).forEach((item) => timelines.push({
        kind: "payment",
        title: `Payment ${item.payment_mode}`,
        subtitle: `Collected ${formatCurrency(item.amount_paid)}`,
        actor: item.executive_name || "Field Executive",
        created_at: item.created_at,
      }));
    }

    timelines.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

    if (!timelines.length) {
      activityRoot.innerHTML = '<div class="rounded-lg bg-surface-container-low p-4 text-sm text-on-surface-variant">No live visit or payment activity has been recorded for this case yet.</div>';
      return;
    }

    activityRoot.innerHTML = timelines.slice(0, 8).map((entry) => `
      <div class="timeline-item relative flex gap-4 pb-6">
        <div class="timeline-dot relative z-10 flex-shrink-0 w-4 h-4 rounded-full ${entry.kind === "payment" ? "bg-tertiary" : "bg-primary"} border-2 border-white shadow-sm mt-1.5"></div>
        <div class="flex-1 space-y-1">
          <div class="flex justify-between items-start gap-3">
            <p class="font-body-lg text-body-lg font-bold text-on-background">${escapeHtml(entry.title)}</p>
            <span class="text-[12px] text-secondary">${escapeHtml(formatTimestamp(entry.created_at))}</span>
          </div>
          <p class="font-body-md text-body-md text-on-surface-variant">${escapeHtml(entry.subtitle)}</p>
          <p class="text-[12px] text-primary flex items-center gap-1"><span class="material-symbols-outlined text-[14px]">person</span>${escapeHtml(entry.actor)}</p>
        </div>
      </div>
    `).join("");
  }

  function subscribeRealtimeEvents() {
    if (!supabaseClient || realtimeChannel) return;

    realtimeChannel = supabaseClient.channel(REALTIME_CHANNEL);
    realtimeChannel.on("postgres_changes", { event: "*", schema: "public", table: "cases" }, async () => {
      await bindDashboardMetrics();
    });

    Promise.all([isTableAvailable("case_payments"), isTableAvailable("case_visits")]).then(([hasPayments, hasVisits]) => {
      if (hasPayments) {
        realtimeChannel.on("postgres_changes", { event: "*", schema: "public", table: "case_payments" }, async () => {
          await refreshSelectedCaseFromCloud();
          await loadActivityTimeline();
          await bindDashboardMetrics();
        });
      }
      if (hasVisits) {
        realtimeChannel.on("postgres_changes", { event: "*", schema: "public", table: "case_visits" }, async () => {
          await refreshSelectedCaseFromCloud();
          await loadActivityTimeline();
          await bindDashboardMetrics();
        });
      }
      realtimeChannel.subscribe();
    });
  }

  function startOneMinuteAutoSync() {
    if (syncTimer) window.clearInterval(syncTimer);
    syncTimer = window.setInterval(async () => {
      await bindDashboardMetrics();
    }, 60000);
  }

  async function initBridge() {
    supabaseClient = createSupabaseClient();
    if (!supabaseClient) {
      console.error("[LOT Bridge] Supabase client unavailable.");
      return;
    }

    window.lotSupabase = supabaseClient;
    bindCaseSelectionEvents();
    bindAuthForms();
    bindSyncForms();
    await bindPaymentForms();
    await bindVisitForms();
    await bindDashboardMetrics();
    subscribeRealtimeEvents();
    startOneMinuteAutoSync();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => loadSupabaseSDK(initBridge));
  } else {
    loadSupabaseSDK(initBridge);
  }
})();
