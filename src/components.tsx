import React from 'react'
import { useApp } from './context'
import type { Screen } from './types'

// ─── Back Button ─────────────────────────────────────────────────────────────

export function BackButton({ label }: { label?: string }) {
  const { back } = useApp()
  return (
    <button onClick={back} className="flex items-center gap-1.5 text-slate-700 hover:text-slate-900 transition-colors">
      <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
        <path d="M12 15L7 10L12 5" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
      {label && <span className="text-sm font-medium">{label}</span>}
    </button>
  )
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

const statusStyles: Record<string, string> = {
  pending: 'bg-amber-50 text-amber-700 border border-amber-200',
  confirmed: 'bg-blue-50 text-blue-700 border border-blue-200',
  'out-for-delivery': 'bg-violet-50 text-violet-700 border border-violet-200',
  delivered: 'bg-emerald-50 text-emerald-700 border border-emerald-200',
  cancelled: 'bg-red-50 text-red-600 border border-red-200',
  approved: 'bg-emerald-50 text-emerald-700 border border-emerald-200',
  inactive: 'bg-slate-100 text-slate-500 border border-slate-200',
}

const statusLabels: Record<string, string> = {
  pending: 'PENDING',
  confirmed: 'CONFIRMED',
  'out-for-delivery': 'OUT FOR DELIVERY',
  delivered: 'DELIVERED',
  cancelled: 'CANCELLED',
  approved: 'APPROVED',
  inactive: 'INACTIVE',
}

export function StatusBadge({ status }: { status: string }) {
  return (
    <span className={`text-[10px] font-semibold tracking-wide px-2 py-0.5 rounded-full ${statusStyles[status] ?? 'bg-slate-100 text-slate-600'}`}>
      {statusLabels[status] ?? status.toUpperCase()}
    </span>
  )
}

// ─── Toggle ───────────────────────────────────────────────────────────────────

export function Toggle({ checked, onChange }: { checked: boolean; onChange: (v: boolean) => void }) {
  return (
    <button
      onClick={() => onChange(!checked)}
      className={`relative w-12 h-6 rounded-full transition-colors duration-200 ${checked ? 'bg-violet-600' : 'bg-slate-200'}`}
    >
      <span className={`absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow-sm transition-transform duration-200 ${checked ? 'translate-x-6' : 'translate-x-0'}`} />
    </button>
  )
}

// ─── Cart Bar ─────────────────────────────────────────────────────────────────

export function CartBar({ total }: { total: number }) {
  const { cart, navigate } = useApp()
  if (cart.length === 0) return null
  const count = cart.reduce((s, i) => s + i.qty, 0)
  return (
    <div className="slide-up fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-[430px] px-4 pb-4 z-40 pointer-events-none">
      <button
        onClick={() => navigate('cart')}
        className="pointer-events-auto w-full flex items-center justify-between bg-slate-900 text-white px-4 py-3.5 rounded-2xl shadow-xl"
      >
        <div className="flex items-center gap-2">
          <span className="bg-violet-500 text-white text-xs font-bold px-2 py-0.5 rounded-full">{count}</span>
          <span className="text-sm font-medium">items</span>
        </div>
        <span className="font-semibold">View Cart →</span>
        <span className="text-violet-300 font-bold">₹{total.toLocaleString('en-IN')}</span>
      </button>
    </div>
  )
}

// ─── Bottom Nav (Customer) ────────────────────────────────────────────────────

const customerTabs: { id: Screen; label: string; icon: string }[] = [
  { id: 'home', label: 'Home', icon: '🏠' },
  { id: 'search', label: 'Search', icon: '🔍' },
  { id: 'my-orders', label: 'Orders', icon: '📋' },
  { id: 'profile', label: 'Profile', icon: '👤' },
]

export function BottomNav() {
  const { screen, navigate, unreadCount } = useApp()
  const active = customerTabs.find(t => t.id === screen) ? screen : 'home'
  return (
    <div className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-[430px] bg-white border-t border-slate-100 z-30">
      <div className="flex">
        {customerTabs.map(tab => (
          <button
            key={tab.id}
            onClick={() => navigate(tab.id)}
            className={`flex-1 flex flex-col items-center gap-0.5 py-2.5 transition-colors ${active === tab.id ? 'text-violet-600' : 'text-slate-400'}`}
          >
            <span className="text-xl leading-none relative">
              {tab.icon}
              {tab.id === 'my-orders' && unreadCount > 0 && (
                <span className="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full" />
              )}
            </span>
            <span className={`text-[10px] font-medium ${active === tab.id ? 'text-violet-600' : 'text-slate-400'}`}>{tab.label}</span>
          </button>
        ))}
      </div>
      <div className="h-safe-bottom bg-white" />
    </div>
  )
}

// ─── Admin Bottom Nav ─────────────────────────────────────────────────────────

const adminTabs: { id: Screen; label: string; icon: string }[] = [
  { id: 'admin-dashboard', label: 'Dashboard', icon: '📊' },
  { id: 'admin-orders', label: 'Orders', icon: '📦' },
  { id: 'admin-catalog', label: 'Catalog', icon: '🏷️' },
  { id: 'admin-retailers', label: 'Retailers', icon: '🏪' },
]

export function AdminBottomNav() {
  const { screen, navigate } = useApp()
  const active = adminTabs.find(t => screen.startsWith(t.id)) ? screen : 'admin-dashboard'
  return (
    <div className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-[430px] bg-white border-t border-slate-100 z-30">
      <div className="flex">
        {adminTabs.map(tab => {
          const isActive = screen === tab.id || screen.startsWith(tab.id + '-') || active === tab.id
          return (
            <button
              key={tab.id}
              onClick={() => navigate(tab.id)}
              className={`flex-1 flex flex-col items-center gap-0.5 py-2.5 transition-colors ${isActive ? 'text-violet-600' : 'text-slate-400'}`}
            >
              <span className="text-xl leading-none">{tab.icon}</span>
              <span className={`text-[10px] font-medium ${isActive ? 'text-violet-600' : 'text-slate-400'}`}>{tab.label}</span>
            </button>
          )
        })}
      </div>
    </div>
  )
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

export function Avatar({ name, size = 'md', color = '#7C3AED' }: { name: string; size?: 'sm' | 'md' | 'lg'; color?: string }) {
  const sizeClass = size === 'sm' ? 'w-8 h-8 text-sm' : size === 'lg' ? 'w-14 h-14 text-xl' : 'w-10 h-10 text-base'
  return (
    <div className={`${sizeClass} rounded-full flex items-center justify-center font-bold text-white flex-shrink-0`} style={{ backgroundColor: color }}>
      {name[0]?.toUpperCase()}
    </div>
  )
}

// ─── Spinner ──────────────────────────────────────────────────────────────────

export function Spinner({ color = '#7C3AED' }: { color?: string }) {
  return (
    <div className="w-8 h-8 rounded-full border-2 border-slate-200 spin" style={{ borderTopColor: color }} />
  )
}

// ─── Section Header ───────────────────────────────────────────────────────────

export function SectionHeader({ title, action, onAction }: { title: string; action?: string; onAction?: () => void }) {
  return (
    <div className="flex items-center justify-between mb-3">
      <h2 className="text-base font-bold text-slate-900">{title}</h2>
      {action && (
        <button onClick={onAction} className="text-sm font-medium text-violet-600">{action}</button>
      )}
    </div>
  )
}

// ─── Form Field ───────────────────────────────────────────────────────────────

export function FormField({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="space-y-1.5">
      <label className="text-[13px] font-medium text-slate-600">{label}</label>
      {children}
    </div>
  )
}

export function Input({ className = '', ...props }: React.InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      className={`w-full px-3.5 py-3 rounded-xl border border-slate-200 bg-white text-slate-900 text-sm focus:border-violet-500 focus:ring-2 focus:ring-violet-100 transition-all ${className}`}
      {...props}
    />
  )
}

export function Select({ className = '', children, ...props }: React.SelectHTMLAttributes<HTMLSelectElement> & { children: React.ReactNode }) {
  return (
    <select
      className={`w-full px-3.5 py-3 rounded-xl border border-slate-200 bg-white text-slate-900 text-sm focus:border-violet-500 focus:ring-2 focus:ring-violet-100 transition-all appearance-none ${className}`}
      {...props}
    >
      {children}
    </select>
  )
}
