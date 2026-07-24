import type { CaseRow } from '@/types/database.types'
import { toNumber } from './currency'

export function deriveOutstanding(caseRow: CaseRow): number {
  const target = toNumber(caseRow.loan_repay_amount ?? caseRow.loan_amount)
  const collected = toNumber(caseRow.total_collected_amount)
  if (collected > 0) return Math.max(target - collected, 0)
  return target
}

export function deriveEmi(caseRow: CaseRow): number {
  const tenure = toNumber(caseRow.tenure)
  const total = toNumber(caseRow.loan_repay_amount ?? caseRow.loan_amount)
  if (tenure > 0) return total / tenure
  return total
}

export type RiskLevel = 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL'

export function deriveRisk(caseRow: CaseRow): RiskLevel {
  const dueDays = toNumber(caseRow.due_days)
  if (dueDays >= 180) return 'CRITICAL'
  if (dueDays >= 90) return 'HIGH'
  if (dueDays >= 30) return 'MEDIUM'
  return 'LOW'
}

export const RISK_CONFIG: Record<
  RiskLevel,
  { label: string; className: string; color: string }
> = {
  LOW: {
    label: 'Low Risk',
    className: 'bg-green-100 text-green-800 border-green-200',
    color: '#16a34a',
  },
  MEDIUM: {
    label: 'Medium Risk',
    className: 'bg-yellow-100 text-yellow-800 border-yellow-200',
    color: '#ca8a04',
  },
  HIGH: {
    label: 'High Risk',
    className: 'bg-orange-100 text-orange-800 border-orange-200',
    color: '#ea580c',
  },
  CRITICAL: {
    label: 'Critical',
    className: 'bg-red-100 text-red-800 border-red-200',
    color: '#dc2626',
  },
}

export function formatTimestamp(value: string | null | undefined): string {
  if (!value) return 'Just now'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return 'Just now'
  return date.toLocaleString('en-IN', {
    day: '2-digit',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit',
  })
}

export function formatRelativeTime(value: string | null | undefined): string {
  if (!value) return ''
  const diff = Date.now() - new Date(value).getTime()
  const mins = Math.floor(diff / 60000)
  if (mins < 1) return 'Just now'
  if (mins < 60) return `${mins}m ago`
  const hrs = Math.floor(mins / 60)
  if (hrs < 24) return `${hrs}h ago`
  return `${Math.floor(hrs / 24)}d ago`
}
