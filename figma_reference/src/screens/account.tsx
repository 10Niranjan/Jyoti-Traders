// PARTIAL CAPTURE — extracted from Figma Make's code diff panel; the file is
// 460 lines total, this covers roughly the first 210 (MyOrders screen in
// full, OrderDetail screen through the items/totals section). The rest
// (delivery/payment section end, Notifications screen, Profile screen) was
// not captured before the diff panel became unreliable. See
// figma_reference/README.md for how to pull the rest if needed.

import { useState } from 'react'
import { useApp } from '../context'
import { products } from '../data'
import { BackButton, StatusBadge, Toggle } from '../components'

// ─── Shared bottom nav for account screens ────────────────────────────────────

function AccountBottomNav() {
  const { navigate, screen, unreadCount } = useApp()
  const tabs = [
    { id: 'home', label: 'Home', icon: '🏠' },
    { id: 'search', label: 'Search', icon: '🔍' },
    { id: 'my-orders', label: 'Orders', icon: '📋' },
    { id: 'profile', label: 'Profile', icon: '👤' },
  ]
  return (
    <div className="absolute bottom-0 left-0 right-0 bg-white border-t border-slate-100 z-30">
      <div className="flex">
        {tabs.map(tab => (
          <button key={tab.id} onClick={() => navigate(tab.id as any)}
            className={`flex-1 flex flex-col items-center gap-0.5 py-2.5 ${screen === tab.id ? 'text-violet-600' : 'text-slate-400'}`}>
            <span className="text-xl leading-none relative">
              {tab.icon}
              {tab.id === 'my-orders' && unreadCount > 0 && <span className="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full" />}
            </span>
            <span className={`text-[10px] font-medium ${screen === tab.id ? 'text-violet-600' : 'text-slate-400'}`}>{tab.label}</span>
          </button>
        ))}
      </div>
    </div>
  )
}

// ─── My Orders ────────────────────────────────────────────────────────────────

const ORDER_FILTERS = ['All', 'Pending', 'Confirmed', 'Out for Delivery', 'Delivered'] as const
type OrderFilter = typeof ORDER_FILTERS[number]

export function MyOrders() {
  const { orders, navigate } = useApp()
  const [filter, setFilter] = useState<OrderFilter>('All')

  const myOrders = orders.filter(o => o.retailerId === 'sharma')
  const filtered = filter === 'All' ? myOrders : myOrders.filter(o => {
    if (filter === 'Out for Delivery') return o.status === 'out-for-delivery'
    return o.status === filter.toLowerCase()
  })

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-3 border-b border-slate-100">
        <h1 className="text-lg font-bold text-slate-900">My Orders</h1>
      </div>

      {/* Filter chips */}
      <div className="bg-white px-4 pb-3 flex gap-2 overflow-x-auto no-scrollbar">
        {ORDER_FILTERS.map(f => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={`flex-shrink-0 px-3.5 py-1.5 rounded-full text-xs font-semibold border transition-colors ${filter === f ? 'bg-violet-600 text-white border-violet-600' : 'border-slate-200 text-slate-600 hover:border-violet-400'}`}
          >
            {f === 'All' && filter === 'All' && '✓ '}{f}
          </button>
        ))}
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-3 pb-20">
        {filtered.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16 gap-3">
            <span className="text-4xl">📦</span>
            <p className="text-slate-400 text-sm">No orders found</p>
          </div>
        ) : (
          filtered.map(order => (
            <button
              key={order.id}
              onClick={() => navigate('order-detail', { orderId: order.id })}
              className="w-full bg-white rounded-2xl p-4 text-left border border-slate-100 shadow-sm hover:border-violet-200 transition-colors"
            >
              <div className="flex items-start justify-between">
                <div>
                  <p className="text-sm font-bold text-slate-900">Order #{order.id}</p>
                  <p className="text-xs text-slate-400 mt-0.5">{order.items.length} item{order.items.length > 1 ? 's' : ''} · {order.date}</p>
                  <p className="text-base font-bold text-violet-600 mt-1.5">₹{order.total.toLocaleString('en-IN')}</p>
                </div>
                <StatusBadge status={order.status} />
              </div>
            </button>
          ))
        )}
      </div>

      <AccountBottomNav />
    </div>
  )
}

// ─── Order Detail ─────────────────────────────────────────────────────────────

const STATUS_STEPS = ['pending', 'confirmed', 'out-for-delivery', 'delivered'] as const
const STEP_LABELS: Record<string, string> = {
  pending: 'Order Placed',
  confirmed: 'Confirmed',
  'out-for-delivery': 'Out for Delivery',
  delivered: 'Delivered',
}
const STEP_ICONS: Record<string, string> = {
  pending: '📋',
  confirmed: '✅',
  'out-for-delivery': '🚚',
  delivered: '🏠',
}

export function OrderDetail() {
  const { params, orders, navigate } = useApp()
  const orderId = params.orderId as string
  const order = orders.find(o => o.id === orderId)

  if (!order) return (
    <div className="flex-1 flex items-center justify-center">
      <p className="text-slate-400">Order not found</p>
    </div>
  )

  const currentStepIdx = STATUS_STEPS.indexOf(order.status as typeof STATUS_STEPS[number])

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-3 flex items-center justify-between border-b border-slate-100">
        <div className="flex items-center gap-3">
          <BackButton />
          <h1 className="text-base font-bold text-slate-900">Order Details</h1>
        </div>
        <button className="text-slate-400 text-xl">↗</button>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-4 pb-6">
        {/* Header */}
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-base font-bold text-slate-900">Order #{order.id}</p>
              <p className="text-xs text-slate-400 mt-0.5">Placed on {order.date}</p>
            </div>
            <StatusBadge status={order.status} />
          </div>
        </div>

        {/* Order Status Timeline */}
        {order.status !== 'cancelled' && (
          <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
            <p className="text-sm font-bold text-slate-900 mb-4">Order Status</p>
            <div className="space-y-3">
              {STATUS_STEPS.map((step, i) => {
                const done = i <= currentStepIdx
                const active = i === currentStepIdx
                return (
                  <div key={step} className="flex items-center gap-3">
                    <div className={`w-9 h-9 rounded-full flex items-center justify-center text-lg flex-shrink-0 ${done ? 'bg-violet-100' : 'bg-slate-100'} ${active ? 'ring-2 ring-violet-400' : ''}`}>
                      {STEP_ICONS[step]}
                    </div>
                    {i < STATUS_STEPS.length - 1 && (
                      <div className={`absolute ml-4 mt-9 w-0.5 h-3 ${done && i < currentStepIdx ? 'bg-violet-300' : 'bg-slate-200'}`} style={{ position: 'relative', left: -32, top: 0, marginTop: 0 }} />
                    )}
                    <div className="flex-1">
                      <p className={`text-sm font-semibold ${done ? 'text-slate-900' : 'text-slate-400'}`}>{STEP_LABELS[step]}</p>
                    </div>
                    {active && <div className="w-2 h-2 rounded-full bg-violet-500" />}
                    {done && !active && <span className="text-emerald-500 text-sm">✓</span>}
                  </div>
                )
              })}
            </div>
          </div>
        )}

        {/* Items */}
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
          <p className="text-sm font-bold text-slate-900 mb-3">Items</p>
          <div className="space-y-2">
            {order.items.map((item, i) => (
              <div key={i} className="flex justify-between text-sm">
                <span className="text-slate-600">{item.name}</span>
                <span className="font-semibold text-slate-900">₹{item.total.toLocaleString('en-IN')}</span>
              </div>
            ))}
          </div>
          <div className="border-t border-slate-100 mt-3 pt-3 space-y-1">
            <div className="flex justify-between text-sm">
              <span className="text-slate-500">Subtotal</span>
              <span>₹{order.subtotal.toLocaleString('en-IN')}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-slate-500">Delivery Charge</span>
              <span>₹{order.deliveryCharge}</span>
            </div>
            <div className="flex justify-between font-bold text-slate-900 pt-1 border-t border-slate-100">
              <span>Grand Total</span>
              <span>₹{order.total.toLocaleString('en-IN')}</span>
            </div>
          </div>
        </div>

        {/* Delivery & Payment */}
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm space-y-3">
          <div>
            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wide">Delivery Address</p>
            {/* ...capture cut off here — rest of Delivery/Payment block,
                buy-again/cancel actions, plus the Notifications and Profile
                screens further down this file were not captured. */}
          </div>
        </div>
      </div>
    </div>
  )
}

// Notifications and Profile screens (not captured — see README.md)
