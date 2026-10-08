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
            <p className="text-sm text-slate-700 mt-1">{order.address}</p>
          </div>
          <div>
            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wide">Payment</p>
            <p className="text-sm text-slate-700 mt-1">{order.payment}</p>
          </div>
        </div>

        {/* Actions */}
        {order.status !== 'cancelled' && order.status !== 'delivered' && (
          <div className="flex gap-3">
            <button
              onClick={() => {
                const prevOrderedProductIds = order.items.map(i => i.productId)
                prevOrderedProductIds.forEach(id => navigate('product', { productId: id }))
                navigate('home')
              }}
              className="flex-1 flex items-center justify-center gap-1.5 border-2 border-violet-600 text-violet-600 font-semibold py-3 rounded-2xl hover:bg-violet-50 transition-colors text-sm"
            >
              ↺ Buy Again
            </button>
            <button
              className="flex-1 flex items-center justify-center gap-1.5 border-2 border-red-400 text-red-500 font-semibold py-3 rounded-2xl hover:bg-red-50 transition-colors text-sm"
            >
              × Cancel
            </button>
          </div>
        )}
      </div>
    </div>
  )
}

// ─── Notifications ────────────────────────────────────────────────────────────

export function Notifications() {
  const { notifications, markAllRead, unreadCount } = useApp()

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-3 flex items-center justify-between border-b border-slate-100">
        <div className="flex items-center gap-3">
          <BackButton />
          <h1 className="text-lg font-bold text-slate-900">Notifications</h1>
        </div>
        {unreadCount > 0 && (
          <button onClick={markAllRead} className="text-sm font-medium text-violet-600">Mark all read</button>
        )}
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-2">
        {notifications.map(n => (
          <div key={n.id} className={`bg-white rounded-2xl p-4 border shadow-sm transition-colors ${!n.read ? 'border-violet-100 bg-violet-50/40' : 'border-slate-100'}`}>
            <div className="flex items-start gap-2.5">
              {!n.read && <div className="w-2 h-2 rounded-full bg-violet-500 mt-1.5 flex-shrink-0" />}
              <div className={!n.read ? '' : 'pl-4'}>
                <p className={`text-sm font-semibold ${!n.read ? 'text-slate-900' : 'text-slate-600'}`}>{n.title}</p>
                <p className="text-xs text-slate-500 mt-0.5 leading-relaxed">{n.body}</p>
                <p className="text-[10px] text-violet-400 font-medium mt-1.5">{n.time}</p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

// ─── Profile ─────────────────────────────────────────────────────────────────

export function Profile() {
  const { navigate } = useApp()
  const [tab, setTab] = useState<'profile' | 'settings'>('profile')
  const [form, setForm] = useState({
    street: 'MG Road, Shop No. 14', city: 'Pune', pincode: '411001',
    gst: '27ABCDE1234F1Z5', openTime: '09:00 AM', closeTime: '09:00 PM', open24: false,
    accountHolder: 'Ramesh Sharma', accountNo: 'XXXXXXXX4521', ifsc: 'HDFC0001234', bankName: 'HDFC Bank',
  })
  const [notifSettings, setNotifSettings] = useState({ orders: true, promotions: true, lowStock: true })
  const [appearance, setAppearance] = useState<'system' | 'light' | 'dark'>('system')

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-0 border-b border-slate-100">
        <h1 className="text-lg font-bold text-slate-900 mb-3">Profile</h1>
        <div className="flex">
          {(['profile', 'settings'] as const).map(t => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={`flex-1 pb-3 text-sm font-semibold capitalize border-b-2 transition-colors ${tab === t ? 'text-violet-600 border-violet-600' : 'text-slate-400 border-transparent'}`}
            >
              {t === 'settings' ? '⚙ Settings' : 'Profile'}
            </button>
          ))}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-4 pb-24">
        {tab === 'profile' ? (
          <>
            {/* Store card */}
            <div className="bg-violet-600 rounded-2xl p-4 flex items-center gap-3">
              <div className="w-12 h-12 bg-violet-400 rounded-full flex items-center justify-center text-white text-xl font-bold">S</div>
              <div className="flex-1">
                <p className="text-white font-bold text-base">Sharma General Store</p>
                <p className="text-violet-200 text-sm">Ramesh Sharma</p>
                <p className="text-violet-200 text-sm">98765 43210</p>
              </div>
              <button className="text-violet-200 text-xl">✏</button>
            </div>

            {/* Delivery Address */}
            <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm space-y-3">
              <p className="text-sm font-bold text-slate-900">Delivery Address</p>
              <div className="space-y-1">
                <label className="text-xs text-slate-500">Street Address</label>
                <input value={form.street} onChange={e => setForm(f => ({ ...f, street: e.target.value }))} className="w-full px-3 py-2.5 border border-slate-200 rounded-xl text-sm focus:border-violet-400" />
              </div>
              <div className="grid grid-cols-2 gap-2">
                <div className="space-y-1">
                  <label className="text-xs text-slate-500">City</label>
                  <input value={form.city} onChange={e => setForm(f => ({ ...f, city: e.target.value }))} className="w-full px-3 py-2.5 border border-slate-200 rounded-xl text-sm focus:border-violet-400" />
                </div>
                <div className="space-y-1">
                  <label className="text-xs text-slate-500">Pincode</label>
                  <input value={form.pincode} onChange={e => setForm(f => ({ ...f, pincode: e.target.value }))} className="w-full px-3 py-2.5 border border-slate-200 rounded-xl text-sm focus:border-violet-400" />
                </div>
              </div>
            </div>

            {/* Business Details */}
            <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm space-y-3">
              <p className="text-sm font-bold text-slate-900">Business Details</p>
              <div className="space-y-1">
                <label className="text-xs text-slate-500">GST Number (optional)</label>
                <input value={form.gst} onChange={e => setForm(f => ({ ...f, gst: e.target.value }))} className="w-full px-3 py-2.5 border border-slate-200 rounded-xl text-sm focus:border-violet-400" />
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium text-slate-700">Open 24×7</span>
                <Toggle checked={form.open24} onChange={v => setForm(f => ({ ...f, open24: v }))} />
              </div>
              {!form.open24 && (
                <div className="flex gap-2">
                  <button className="flex-1 border border-violet-400 text-violet-600 text-sm font-medium py-2 rounded-xl">Opens: {form.openTime}</button>
                  <button className="flex-1 border border-violet-400 text-violet-600 text-sm font-medium py-2 rounded-xl">Closes: {form.closeTime}</button>
                </div>
              )}
            </div>

            {/* Payout Details */}
            <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm space-y-3">
              <p className="text-sm font-bold text-slate-900">Payout Details</p>
              {[
                { label: 'Account Holder Name', key: 'accountHolder' },
                { label: 'Account Number', key: 'accountNo' },
              ].map(({ label, key }) => (
                <div key={key} className="space-y-1">
                  <label className="text-xs text-slate-500">{label}</label>
                  <input value={form[key as keyof typeof form] as string} onChange={e => setForm(f => ({ ...f, [key]: e.target.value }))} className="w-full px-3 py-2.5 border border-slate-200 rounded-xl text-sm focus:border-violet-400" />
                </div>
              ))}
              <div className="grid grid-cols-2 gap-2">
                {[{ label: 'IFSC Code', key: 'ifsc' }, { label: 'Bank Name', key: 'bankName' }].map(({ label, key }) => (
                  <div key={key} className="space-y-1">
                    <label className="text-xs text-slate-500">{label}</label>
                    <input value={form[key as keyof typeof form] as string} onChange={e => setForm(f => ({ ...f, [key]: e.target.value }))} className="w-full px-3 py-2.5 border border-slate-200 rounded-xl text-sm focus:border-violet-400" />
                  </div>
                ))}
              </div>
            </div>

            <button className="w-full bg-violet-600 hover:bg-violet-700 text-white font-bold py-4 rounded-2xl transition-colors">Save Changes</button>
          </>
        ) : (
          <>
            {/* Notifications */}
            <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm space-y-4">
              <p className="text-sm font-bold text-slate-900">Notifications</p>
              {[
                { key: 'orders', label: 'Order Updates', sub: 'Status changes for your orders' },
                { key: 'promotions', label: 'Promotions', sub: 'Offers and discounts' },
                { key: 'lowStock', label: 'Low Stock Alerts', sub: 'When items you buy often are running low' },
              ].map(({ key, label, sub }) => (
                <div key={key} className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-slate-800">{label}</p>
                    <p className="text-xs text-slate-400">{sub}</p>
                  </div>
                  <Toggle checked={notifSettings[key as keyof typeof notifSettings]} onChange={v => setNotifSettings(s => ({ ...s, [key]: v }))} />
                </div>
              ))}
            </div>

            {/* Appearance */}
            <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
              <p className="text-sm font-bold text-slate-900 mb-3">Appearance</p>
              <div className="flex gap-2">
                {(['system', 'light', 'dark'] as const).map(opt => (
                  <button
                    key={opt}
                    onClick={() => setAppearance(opt)}
                    className={`flex-1 py-2 rounded-xl text-sm font-medium capitalize transition-colors ${appearance === opt ? 'bg-violet-600 text-white' : 'bg-slate-100 text-slate-600 hover:bg-slate-200'}`}
                  >
                    {opt === 'system' ? '⊙ System' : opt === 'light' ? '✳ Light' : '☾ Dark'}
                  </button>
                ))}
              </div>
            </div>

            {/* Account */}
            <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
              <p className="text-sm font-bold text-slate-900 px-4 pt-4 pb-2">Account</p>
              <button className="w-full flex items-center justify-between px-4 py-3 hover:bg-slate-50 transition-colors border-t border-slate-100">
                <div>
                  <p className="text-sm font-medium text-slate-800">Change Password</p>
                  <p className="text-xs text-slate-400">retailer@shop.com</p>
                </div>
                <span className="text-slate-400">›</span>
              </button>
            </div>

            {/* Support */}
            <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
              <p className="text-sm font-bold text-slate-900 px-4 pt-4 pb-2">Support</p>
              <a href="tel:+919860460325" className="flex items-center justify-between px-4 py-3 hover:bg-slate-50 transition-colors border-t border-slate-100">
                <div>
                  <p className="text-sm font-medium text-slate-800">Call Support</p>
                  <p className="text-xs text-slate-400">+91 98604 60325</p>
                </div>
                <span className="text-lg">📞</span>
              </a>
              <a href="mailto:vishvatejkatkar007@gmail.com" className="flex items-center justify-between px-4 py-3 hover:bg-slate-50 transition-colors border-t border-slate-100">
                <div>
                  <p className="text-sm font-medium text-slate-800">Email Support</p>
                  <p className="text-xs text-slate-400">vishvatejkatkar007@gmail.com</p>
                </div>
                <span className="text-lg">✉</span>
              </a>
            </div>

            <button onClick={() => navigate('signin')} className="w-full border-2 border-red-400 text-red-500 font-semibold py-3.5 rounded-2xl hover:bg-red-50 transition-colors">
              ↩ Log Out
            </button>
          </>
        )}
      </div>

      <AccountBottomNav />
    </div>
  )
}
