export function formatCurrency(value: number | null | undefined): string {
  return new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: 'INR',
    maximumFractionDigits: 0,
  }).format(value ?? 0)
}

export function formatCurrencyCompact(value: number | null | undefined): string {
  const num = value ?? 0
  if (num >= 10_000_000) return `₹${(num / 10_000_000).toFixed(2)} Cr`
  if (num >= 100_000) return `₹${(num / 100_000).toFixed(2)} L`
  if (num >= 1000) return `₹${(num / 1000).toFixed(1)}K`
  return formatCurrency(num)
}

export function toNumber(value: unknown): number {
  const num = Number(value)
  return Number.isFinite(num) ? num : 0
}
