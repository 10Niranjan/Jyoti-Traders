import { useState } from 'react'
import { useApp } from '../context'
import { products as allProducts, categories as allCategories, weeklyOrders, weekDays } from '../data'
import { BackButton, StatusBadge, Toggle, Avatar } from '../components'
import type { Order } from '../types'

// ─── Shared Admin Bottom Nav ──────────────────────────────────────────────────

function AdminNav() {
  const { screen, navigate } = useApp()
  const tabs = [
    { id: 'admin-dashboard', label: 'Dashboard', icon: '📊' },
    { id: 'admin-orders', label: 'Orders', icon: '📦' },
    { id: 'admin-catalog', label: 'Catalog', icon: '🏷️' },
    { id: 'admin-retailers', label: 'Retailers', icon: '🏪' },
  ]
  const activeTab = tabs.find(t => screen === t.id || screen.startsWith(t.id))?.id ?? 'admin-dashboard'
  return (
    <div className="absolute bottom-0 left-0 right-0 bg-white border-t border-slate-100 z-30">
      <div className="flex">
        {tabs.map(tab => (
          <button key={tab.id} onClick={() => navigate(tab.id as any)}
            className={`flex-1 flex flex-col items-center gap-0.5 py-2.5 ${activeTab === tab.id ? 'text-violet-600' : 'text-slate-400'}`}>
            <span className="text-xl leading-none">{tab.icon}</span>
            <span className={`text-[10px] font-medium ${activeTab === tab.id ? 'text-violet-600' : 'text-slate-400'}`}>{tab.label}</span>
          </button>
        ))}
      </div>
    </div>
  )
}

// ─── Admin Dashboard ──────────────────────────────────────────────────────────

export function AdminDashboard() {
  const { navigate, retailers, orders } = useApp()

  const pendingApprovals = retailers.filter(r => r.status === 'pending').length
  const totalRetailers = retailers.filter(r => r.status === 'approved').length
  const todayOrders = orders.filter(o => o.date.includes('12 Aug')).length
  const pendingRetailers = retailers.filter(r => r.status === 'pending')
  const maxBar = Math.max(...weeklyOrders)

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-3 flex items-center justify-between border-b border-slate-100">
        <h1 className="text-lg font-bold text-slate-900">Jyoti Traders Admin</h1>
        <div className="flex items-center gap-3">
          <button onClick={() => navigate('notifications')} className="text-xl">🔔</button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-4 pb-20">
        {/* Stat cards */}
        <div className="grid grid-cols-2 gap-3">
          <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
            <div className="flex items-center justify-between mb-2">
              <p className="text-xs font-medium text-slate-500">Pending Approvals</p>
              <span className="text-lg">⏳</span>
            </div>
            <p className="text-3xl font-extrabold text-slate-900">{pendingApprovals}</p>
          </div>
          <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
            <div className="flex items-center justify-between mb-2">
              <p className="text-xs font-medium text-slate-500">Total Retailers</p>
              <span className="text-lg">🏢</span>
            </div>
            <p className="text-3xl font-extrabold text-slate-900">{totalRetailers}</p>
          </div>
        </div>
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
          <div className="flex items-center justify-between mb-2">
            <p className="text-xs font-medium text-slate-500">Today's Orders</p>
            <span className="text-lg">📦</span>
          </div>
          <p className="text-3xl font-extrabold text-slate-900">{todayOrders}</p>
        </div>

        {/* Bar Chart */}
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
          <p className="text-sm font-bold text-slate-900 mb-4">Orders — Last 7 Days</p>
          <div className="flex items-end gap-2 h-20">
            {weeklyOrders.map((val, i) => (
              <div key={i} className="flex-1 flex flex-col items-center gap-1.5">
                <div
                  className="w-full rounded-t-md transition-all"
                  style={{
                    height: `${(val / maxBar) * 64}px`,
                    backgroundColor: i === 5 ? '#7C3AED' : '#C4B5FD',
                  }}
                />
                <span className="text-[9px] text-slate-400">{weekDays[i]}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Delivery Settings Button */}
        <button
          onClick={() => navigate('admin-delivery')}
          className="w-full border-2 border-violet-600 text-violet-600 font-semibold py-3.5 rounded-2xl hover:bg-violet-50 transition-colors text-sm"
        >
          Delivery Settings
        </button>

        {/* Retailer Approval Queue */}
        {pendingRetailers.length > 0 && (
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <p className="text-sm font-bold text-slate-900">Retailer Approval Queue</p>
              <button onClick={() => navigate('admin-retailers')} className="text-xs font-medium text-violet-600">View All</button>
            </div>
            {pendingRetailers.slice(0, 1).map(r => (
              <ApprovalCard key={r.id} retailer={r} />
            ))}
            {pendingRetailers.length > 1 && (
              <p className="text-xs text-slate-400 text-center">+{pendingRetailers.length - 1} more waiting — tap "View All"</p>
            )}
          </div>
        )}
      </div>

      <AdminNav />
    </div>
  )
}

function ApprovalCard({ retailer }: { retailer: ReturnType<typeof useApp>['retailers'][number] }) {
  const { approveRetailer, rejectRetailer } = useApp()
  const [done, setDone] = useState(false)

  if (done) return null

  return (
    <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
      <div className="flex items-center gap-3 mb-3">
        <Avatar name={retailer.name} color="#7C3AED" />
        <div>
          <p className="text-sm font-bold text-slate-900">{retailer.name}</p>
          <p className="text-xs text-slate-500">{retailer.owner} · {retailer.phone}</p>
        </div>
      </div>
      <div className="flex gap-2">
        <button
          onClick={() => { rejectRetailer(retailer.id); setDone(true) }}
          className="flex-shrink-0 text-red-500 font-semibold text-sm py-2 px-3"
        >
          Reject
        </button>
        <button
          onClick={() => { approveRetailer(retailer.id); setDone(true) }}
          className="flex-1 flex items-center justify-center gap-1.5 bg-emerald-500 hover:bg-emerald-600 text-white font-semibold py-2.5 rounded-xl transition-colors text-sm"
        >
          ✓ Approve
        </button>
      </div>
    </div>
  )
}

// ─── Admin Orders ─────────────────────────────────────────────────────────────

const ORDER_FILTERS = ['All', 'Pending', 'Confirmed', 'Delivered'] as const

export function AdminOrders() {
  const { orders, navigate } = useApp()
  const [filter, setFilter] = useState<string>('All')

  const filtered = filter === 'All' ? orders : orders.filter(o => {
    if (filter === 'Delivered') return o.status === 'delivered'
    if (filter === 'Confirmed') return o.status === 'confirmed'
    if (filter === 'Pending') return o.status === 'pending'
    return true
  })

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-0 border-b border-slate-100">
        <div className="flex items-center justify-between mb-3">
          <h1 className="text-lg font-bold text-slate-900">All Orders</h1>
          <button className="text-slate-400 text-xl">↗</button>
        </div>
        <div className="flex gap-2 pb-3 overflow-x-auto no-scrollbar">
          {ORDER_FILTERS.map(f => (
            <button key={f} onClick={() => setFilter(f)}
              className={`flex-shrink-0 px-3.5 py-1.5 rounded-full text-xs font-semibold border transition-colors ${filter === f ? 'bg-violet-600 text-white border-violet-600' : 'border-slate-200 text-slate-600'}`}>
              {f === 'All' && filter === 'All' && '✓ '}{f}
            </button>
          ))}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-3 pb-20">
        {filtered.map(order => (
          <button key={order.id} onClick={() => navigate('admin-order-detail', { orderId: order.id })}
            className="w-full bg-white rounded-2xl p-4 text-left border border-slate-100 shadow-sm hover:border-violet-200 transition-colors">
            <div className="flex items-start justify-between mb-1">
              <p className="text-sm font-bold text-slate-900">Order #{order.id}</p>
              <StatusBadge status={order.status} />
            </div>
            <p className="text-xs font-medium text-violet-600">{order.retailerName}</p>
            <p className="text-xs text-slate-400 mt-0.5">{order.items.length} items · {order.date}</p>
            <p className="text-base font-bold text-slate-900 mt-1.5">₹{order.total.toLocaleString('en-IN')}</p>
          </button>
        ))}
      </div>

      <AdminNav />
    </div>
  )
}

// ─── Admin Order Detail ───────────────────────────────────────────────────────

export function AdminOrderDetail() {
  const { params, orders, updateOrderStatus, markOrderPaid } = useApp()
  const orderId = params.orderId as string
  const order = orders.find(o => o.id === orderId)
  const [status, setStatus] = useState(order?.status ?? 'pending')
  const [saved, setSaved] = useState(false)

  if (!order) return null

  const handleStatusChange = (newStatus: Order['status']) => {
    setStatus(newStatus)
    updateOrderStatus(order.id, newStatus)
    setSaved(true)
    setTimeout(() => setSaved(false), 2000)
  }

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-3 flex items-center gap-3 border-b border-slate-100">
        <BackButton />
        <h1 className="text-base font-bold text-slate-900">Manage Order</h1>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-4 pb-6">
        {/* Header */}
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
          <div className="flex items-start justify-between mb-1">
            <p className="text-base font-bold text-slate-900">Order #{order.id}</p>
            <StatusBadge status={status} />
          </div>
          <p className="text-xs font-medium text-violet-600">{order.retailerName}</p>
        </div>

        {/* Status Selector */}
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
          <p className="text-xs text-slate-500 mb-1">Order status</p>
          <div className="relative">
            <select
              value={status}
              onChange={e => handleStatusChange(e.target.value as Order['status'])}
              className="w-full px-3.5 py-3 rounded-xl border border-slate-200 text-sm font-medium text-slate-800 focus:border-violet-400 appearance-none bg-white pr-8"
            >
              <option value="pending">Pending</option>
              <option value="confirmed">Confirmed</option>
              <option value="out-for-delivery">Out for Delivery</option>
              <option value="delivered">Delivered</option>
              <option value="cancelled">Cancelled</option>
            </select>
            <span className="absolute right-3 top-3 text-slate-400 pointer-events-none">▼</span>
          </div>
          {saved && <p className="text-xs text-emerald-500 font-medium mt-1.5">✓ Status updated</p>}
        </div>

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
          <div className="border-t border-slate-100 mt-3 pt-2 flex justify-between font-bold text-slate-900">
            <span>Grand Total</span>
            <span>₹{order.total.toLocaleString('en-IN')}</span>
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
            <p className="text-sm text-slate-700 mt-1">{order.payment} — {order.paid ? 'Paid' : 'Unpaid'}</p>
          </div>
        </div>

        {!order.paid && (
          <button
            onClick={() => markOrderPaid(order.id)}
            className="w-full border-2 border-emerald-500 text-emerald-600 font-semibold py-3.5 rounded-2xl hover:bg-emerald-50 transition-colors flex items-center justify-center gap-2"
          >
            ✓ Mark as Paid
          </button>
        )}
      </div>
    </div>
  )
}

// ─── Admin Catalog ─────────────────────────────────────────────────────────────

export function AdminCatalog() {
  const { navigate } = useApp()
  const [tab, setTab] = useState<'products' | 'categories'>('products')
  const [catList, setCatList] = useState(allCategories)
  const [prodList, setProdList] = useState(allProducts)

  const lowStockProducts = prodList.filter(p => p.stock <= 10)

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-0 border-b border-slate-100">
        <h1 className="text-lg font-bold text-slate-900 mb-3">Catalog</h1>
        <div className="flex">
          {(['products', 'categories'] as const).map(t => (
            <button key={t} onClick={() => setTab(t)}
              className={`flex-1 pb-3 text-sm font-semibold capitalize border-b-2 transition-colors ${tab === t ? 'text-violet-600 border-violet-600' : 'text-slate-400 border-transparent'}`}>
              {t === 'categories' ? '🏷 Categories' : 'Products'}
            </button>
          ))}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-3 pb-24">
        {tab === 'products' ? (
          <>
            {lowStockProducts.length > 0 && (
              <div className="bg-red-50 border border-red-200 rounded-xl px-3.5 py-2.5 flex items-center gap-2">
                <span>⚠️</span>
                <p className="text-xs text-red-700 font-medium">{lowStockProducts.length} product(s) are low on stock (≤10).</p>
              </div>
            )}
            {prodList.map(p => {
              const cat = allCategories.find(c => c.id === p.categoryId)
              return (
                <div key={p.id} className="bg-white rounded-2xl p-3.5 flex items-center gap-3 border border-slate-100 shadow-sm">
                  <div className="w-12 h-12 rounded-xl flex items-center justify-center text-2xl flex-shrink-0" style={{ backgroundColor: (cat?.bgColor ?? '#7C3AED') + '18' }}>
                    {p.emoji}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-semibold text-slate-800 truncate">{p.name}</p>
                    <p className="text-xs text-violet-600 font-medium">from ₹{p.price}/{p.unit}</p>
                    {p.stock <= 10
                      ? <p className="text-[10px] text-red-500 font-medium">▲ Stock: {p.stock}</p>
                      : <p className="text-[10px] text-slate-400">Stock: {p.stock}</p>
                    }
                  </div>
                  <div className="flex flex-col gap-1">
                    <button onClick={() => navigate('admin-product-form', { productId: p.id })} className="text-violet-400 hover:text-violet-600 text-lg">✏</button>
                    <button onClick={() => setProdList(l => l.filter(x => x.id !== p.id))} className="text-red-400 hover:text-red-600 text-lg">🗑</button>
                  </div>
                </div>
              )
            })}
          </>
        ) : (
          <>
            {catList.map(cat => (
              <div key={cat.id} className="bg-white rounded-2xl p-3.5 flex items-center gap-3 border border-slate-100 shadow-sm">
                <span className="text-slate-300 text-lg cursor-grab">⋮⋮</span>
                <div className="w-11 h-11 rounded-xl flex items-center justify-center text-2xl flex-shrink-0" style={{ backgroundColor: cat.bgColor }}>
                  {cat.emoji}
                </div>
                <div className="flex-1">
                  <p className="text-sm font-semibold text-slate-800">{cat.name}</p>
                  {!cat.active && <span className="text-[10px] text-slate-400 font-medium uppercase tracking-wide">Inactive</span>}
                </div>
                <div className="flex flex-col gap-1">
                  <button onClick={() => navigate('admin-category-form', { categoryId: cat.id })} className="text-violet-400 hover:text-violet-600 text-lg">✏</button>
                  <button onClick={() => setCatList(l => l.filter(c => c.id !== cat.id))} className="text-red-400 hover:text-red-600 text-lg">🗑</button>
                </div>
              </div>
            ))}
          </>
        )}
      </div>

      {/* FAB */}
      <div className="absolute bottom-16 right-4">
        <button
          onClick={() => navigate(tab === 'products' ? 'admin-product-form' : 'admin-category-form', {})}
          className="bg-violet-600 hover:bg-violet-700 text-white font-semibold px-5 py-3 rounded-full shadow-xl transition-colors text-sm"
        >
          + Add {tab === 'products' ? 'Product' : 'Category'}
        </button>
      </div>

      <AdminNav />
    </div>
  )
}

// ─── Admin Retailers ──────────────────────────────────────────────────────────

export function AdminRetailers() {
  const { navigate, retailers, approveRetailer, rejectRetailer } = useApp()
  const [tab, setTab] = useState<'approved' | 'pending'>('approved')

  const approved = retailers.filter(r => r.status === 'approved')
  const pending = retailers.filter(r => r.status === 'pending')

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-0 border-b border-slate-100">
        <h1 className="text-lg font-bold text-slate-900 mb-3">Retailers</h1>
        <div className="flex">
          <button onClick={() => setTab('approved')}
            className={`flex-1 pb-3 text-sm font-semibold border-b-2 transition-colors ${tab === 'approved' ? 'text-violet-600 border-violet-600' : 'text-slate-400 border-transparent'}`}>
            Approved
          </button>
          <button onClick={() => setTab('pending')}
            className={`flex-1 pb-3 text-sm font-semibold border-b-2 transition-colors ${tab === 'pending' ? 'text-violet-600 border-violet-600' : 'text-slate-400 border-transparent'}`}>
            Pending ({pending.length})
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-3 pb-20">
        {tab === 'approved' ? (
          approved.length === 0 ? (
            <div className="flex flex-col items-center py-12 gap-3">
              <span className="text-4xl">🏪</span>
              <p className="text-slate-400 text-sm">No approved retailers yet</p>
            </div>
          ) : (
            approved.map(r => (
              <button key={r.id} onClick={() => navigate('admin-retailer-detail', { retailerId: r.id })}
                className="w-full bg-white rounded-2xl p-4 text-left border border-slate-100 shadow-sm hover:border-violet-200 transition-colors flex items-center gap-3">
                <Avatar name={r.name} size="md" />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-bold text-slate-900">{r.name}</p>
                  <p className="text-xs text-slate-400">{r.owner}</p>
                </div>
                <div className="text-right">
                  <p className="text-sm font-bold text-violet-600">₹{r.totalSpend.toLocaleString('en-IN')}</p>
                  <p className="text-xs text-slate-400">{r.orderCount} orders</p>
                </div>
              </button>
            ))
          )
        ) : (
          pending.length === 0 ? (
            <div className="flex flex-col items-center py-12 gap-3">
              <span className="text-4xl">✅</span>
              <p className="text-slate-400 text-sm">All retailers reviewed</p>
            </div>
          ) : (
            pending.map(r => (
              <div key={r.id} className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
                <div className="flex items-start gap-3 mb-3">
                  <Avatar name={r.name} />
                  <div className="flex-1">
                    <p className="text-sm font-bold text-slate-900">{r.name}</p>
                    <p className="text-xs text-slate-500">{r.owner} · {r.phone}</p>
                    <p className="text-xs text-slate-400">{r.address}, {r.city}</p>
                  </div>
                  <button onClick={() => navigate('admin-retailer-detail', { retailerId: r.id })} className="text-xs text-violet-600 font-medium flex-shrink-0">Details</button>
                </div>
                <div className="flex gap-2">
                  <button onClick={() => rejectRetailer(r.id)} className="flex-shrink-0 text-red-500 font-semibold text-sm py-2 px-3">Reject</button>
                  <button onClick={() => approveRetailer(r.id)}
                    className="flex-1 flex items-center justify-center gap-1.5 bg-emerald-500 hover:bg-emerald-600 text-white font-semibold py-2.5 rounded-xl transition-colors text-sm">
                    ✓ Approve
                  </button>
                </div>
              </div>
            ))
          )
        )}
      </div>

      <AdminNav />
    </div>
  )
}

// ─── Admin Retailer Detail ─────────────────────────────────────────────────────

export function AdminRetailerDetail() {
  const { params, retailers, approveRetailer, rejectRetailer, back } = useApp()
  const retailerId = params.retailerId as string
  const retailer = retailers.find(r => r.id === retailerId)

  if (!retailer) return null

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-3 flex items-center gap-3 border-b border-slate-100">
        <BackButton />
        <h1 className="text-base font-bold text-slate-900 truncate">{retailer.name}</h1>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-4 pb-6">
        {/* Store card */}
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm flex items-center gap-3">
          <Avatar name={retailer.name} size="lg" />
          <div className="flex-1">
            <p className="text-base font-bold text-slate-900">{retailer.name}</p>
          </div>
          <StatusBadge status={retailer.status} />
        </div>

        {/* Info sections */}
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm space-y-3">
          {[
            { label: 'Owner', value: retailer.owner },
            { label: 'Contact', value: `${retailer.email}\n${retailer.phone}` },
            { label: 'Address', value: `${retailer.address}, ${retailer.city}, ${retailer.pincode}` },
            { label: 'GST', value: retailer.gst || '—' },
            { label: 'Business Hours', value: retailer.hours },
            { label: 'Bank Details', value: `${retailer.accountHolder}\n${retailer.accountNo} · ${retailer.ifsc}\n${retailer.bankName}` },
            { label: 'Registered On', value: retailer.registeredOn },
          ].map(({ label, value }) => (
            <div key={label}>
              <p className="text-xs font-semibold text-violet-600 mb-0.5">{label}</p>
              <p className="text-sm text-slate-700 whitespace-pre-line">{value}</p>
            </div>
          ))}
        </div>

        {/* Actions */}
        {retailer.status === 'pending' && (
          <div className="flex gap-2">
            <button onClick={() => { rejectRetailer(retailer.id); back() }} className="flex-shrink-0 border-2 border-red-400 text-red-500 font-semibold py-3 px-4 rounded-2xl hover:bg-red-50 transition-colors text-sm">Reject</button>
            <button onClick={() => { approveRetailer(retailer.id); back() }}
              className="flex-1 flex items-center justify-center gap-1.5 bg-emerald-500 hover:bg-emerald-600 text-white font-semibold py-3 rounded-2xl transition-colors">
              ✓ Approve
            </button>
          </div>
        )}
      </div>
    </div>
  )
}

// ─── Admin Delivery Settings ──────────────────────────────────────────────────

export function AdminDeliverySettings() {
  const [lat, setLat] = useState('18.5204')
  const [lng, setLng] = useState('73.8567')
  const [rate, setRate] = useState('8.00')
  const [saved, setSaved] = useState(false)

  const handleSave = () => {
    setSaved(true)
    setTimeout(() => setSaved(false), 2500)
  }

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-3 flex items-center gap-3 border-b border-slate-100">
        <BackButton />
        <h1 className="text-base font-bold text-slate-900">Delivery Settings</h1>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-4">
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm space-y-4">
          <div>
            <p className="text-sm font-bold text-slate-900">Warehouse Location</p>
            <p className="text-xs text-slate-400 mt-0.5">Every delivery charge is calculated as straight-line distance from this point.</p>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-1">
              <label className="text-xs text-slate-500">Latitude</label>
              <input value={lat} onChange={e => setLat(e.target.value)} className="w-full px-3 py-2.5 border border-slate-200 rounded-xl text-sm focus:border-violet-400" />
            </div>
            <div className="space-y-1">
              <label className="text-xs text-slate-500">Longitude</label>
              <input value={lng} onChange={e => setLng(e.target.value)} className="w-full px-3 py-2.5 border border-slate-200 rounded-xl text-sm focus:border-violet-400" />
            </div>
          </div>
          <button className="text-sm font-medium text-violet-600 hover:text-violet-700">Use current location</button>
        </div>

        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm space-y-3">
          <p className="text-sm font-bold text-slate-900">Per-km Rate</p>
          <div className="space-y-1">
            <label className="text-xs text-slate-500">Rate (₹ per km)</label>
            <div className="relative">
              <span className="absolute left-3.5 top-3 text-slate-500 text-sm font-medium">₹</span>
              <input value={rate} onChange={e => setRate(e.target.value)} className="w-full pl-8 pr-3 py-2.5 border-2 border-violet-400 rounded-xl text-sm focus:ring-2 focus:ring-violet-100 bg-violet-50" />
            </div>
          </div>
        </div>

        {saved && (
          <div className="slide-up bg-emerald-50 border border-emerald-200 rounded-xl px-4 py-3 text-sm text-emerald-700 font-medium flex items-center gap-2">
            ✓ Delivery settings saved successfully
          </div>
        )}

        <button onClick={handleSave} className="w-full bg-violet-600 hover:bg-violet-700 text-white font-bold py-4 rounded-2xl transition-colors">Save Changes</button>
      </div>
    </div>
  )
}

// ─── Admin Product Form ────────────────────────────────────────────────────────

export function AdminProductForm() {
  const { params, back } = useApp()
  const existingId = params.productId as string | undefined
  const existing = existingId ? allProducts.find(p => p.id === existingId) : undefined

  const [form, setForm] = useState({
    name: existing?.name ?? '',
    categoryId: existing?.categoryId ?? 'grains',
    unit: existing?.unit ?? 'kg',
    price0: existing?.priceTiers?.[0]?.price?.toString() ?? '75',
    price1: existing?.priceTiers?.[1]?.price?.toString() ?? '70',
    price2: existing?.priceTiers?.[2]?.price?.toString() ?? '68',
    price3: existing?.priceTiers?.[3]?.price?.toString() ?? '65',
    stock: existing?.stock?.toString() ?? '0',
    active: existing?.active ?? true,
  })
  const [saved, setSaved] = useState(false)

  const handleSave = () => {
    setSaved(true)
    setTimeout(() => { setSaved(false); back() }, 1200)
  }

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-3 flex items-center gap-3 border-b border-slate-100">
        <BackButton />
        <h1 className="text-base font-bold text-slate-900">{existing ? 'Edit' : 'Add'} Product</h1>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-4 pb-6">
        {/* Image */}
        <button className="w-full border-2 border-dashed border-slate-200 rounded-2xl py-8 flex flex-col items-center gap-2 text-slate-400 hover:border-violet-400 hover:text-violet-500 transition-colors">
          <span className="text-2xl">🖼️</span>
          <span className="text-sm">Tap to {existing ? 'change' : 'add'} image</span>
        </button>

        <div className="space-y-3">
          <div className="space-y-1">
            <label className="text-xs font-medium text-slate-600">Product name</label>
            <input value={form.name} onChange={e => setForm(f => ({ ...f, name: e.target.value }))} placeholder="e.g. Basmati Rice Premium 25kg"
              className="w-full px-3.5 py-3 rounded-xl border-2 border-violet-400 text-sm focus:ring-2 focus:ring-violet-100 bg-white" />
          </div>

          <div className="space-y-1">
            <label className="text-xs font-medium text-slate-600">Category</label>
            <div className="relative">
              <select value={form.categoryId} onChange={e => setForm(f => ({ ...f, categoryId: e.target.value }))}
                className="w-full px-3.5 py-3 rounded-xl border border-slate-200 text-sm bg-white appearance-none pr-8">
                {allCategories.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
              </select>
              <span className="absolute right-3 top-3 text-slate-400 pointer-events-none">▼</span>
            </div>
          </div>

          <div className="space-y-1">
            <label className="text-xs font-medium text-slate-600">Unit</label>
            <div className="relative">
              <select value={form.unit} onChange={e => setForm(f => ({ ...f, unit: e.target.value }))}
                className="w-full px-3.5 py-3 rounded-xl border border-slate-200 text-sm bg-white appearance-none pr-8">
                {['kg', 'tin', 'can', 'pouch', 'litre', 'pack', 'box'].map(u => <option key={u} value={u}>per {u}</option>)}
              </select>
              <span className="absolute right-3 top-3 text-slate-400 pointer-events-none">▼</span>
            </div>
          </div>
        </div>

        {/* Price tiers */}
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm space-y-3">
          <p className="text-sm font-bold text-slate-900">Rate by quantity (₹ per {form.unit})</p>
          <p className="text-xs text-slate-400">The whole weight is billed at the one rate its band earns.</p>
          <div className="grid grid-cols-2 gap-2">
            {['Below 240g', '240g – 999g', '1kg – 2.4kg', 'Above 2.4kg'].map((label, i) => (
              <div key={i} className="space-y-1">
                <label className="text-[10px] text-slate-500">{label}</label>
                <div className="relative">
                  <span className="absolute left-2.5 top-2.5 text-slate-500 text-xs">₹</span>
                  <input
                    value={form[`price${i}` as keyof typeof form] as string}
                    onChange={e => setForm(f => ({ ...f, [`price${i}`]: e.target.value }))}
                    className="w-full pl-6 pr-2.5 py-2 border border-slate-200 rounded-lg text-sm focus:border-violet-400"
                  />
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="space-y-1">
          <label className="text-xs font-medium text-slate-600">Stock quantity</label>
          <input value={form.stock} onChange={e => setForm(f => ({ ...f, stock: e.target.value }))}
            className="w-full px-3.5 py-3 rounded-xl border border-slate-200 text-sm focus:border-violet-400 bg-white" />
          <p className="text-[11px] text-slate-400">In {form.unit === 'kg' ? 'kilograms' : form.unit + 's'}</p>
        </div>

        <div className="flex items-start justify-between bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
          <div>
            <p className="text-sm font-semibold text-slate-800">Active</p>
            <p className="text-xs text-slate-400 mt-0.5 leading-relaxed">Inactive products stay in your catalog but are hidden from retailers.</p>
          </div>
          <Toggle checked={form.active} onChange={v => setForm(f => ({ ...f, active: v }))} />
        </div>

        {saved && <p className="text-center text-sm text-emerald-600 font-medium">✓ Saved successfully</p>}

        <button onClick={handleSave} className="w-full bg-violet-600 hover:bg-violet-700 text-white font-bold py-4 rounded-2xl transition-colors">
          {existing ? 'Save Changes' : 'Add Product'}
        </button>
      </div>
    </div>
  )
}

// ─── Admin Category Form ──────────────────────────────────────────────────────

export function AdminCategoryForm() {
  const { params, back } = useApp()
  const existingId = params.categoryId as string | undefined
  const existing = existingId ? allCategories.find(c => c.id === existingId) : undefined

  const [name, setName] = useState(existing?.name ?? '')
  const [active, setActive] = useState(existing?.active ?? true)
  const [saved, setSaved] = useState(false)

  const handleSave = () => {
    if (!name.trim()) return
    setSaved(true)
    setTimeout(() => { setSaved(false); back() }, 1000)
  }

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-3 flex items-center gap-3 border-b border-slate-100">
        <BackButton />
        <h1 className="text-base font-bold text-slate-900">{existing ? 'Edit' : 'Add'} Category</h1>
      </div>

      <div className="p-4 space-y-4">
        {/* Image */}
        <button className="w-full border-2 border-dashed border-slate-200 rounded-2xl py-10 flex flex-col items-center gap-2 text-slate-400 hover:border-violet-400 hover:text-violet-500 transition-colors">
          <span className="text-2xl">🖼️</span>
          <span className="text-sm">Tap to {existing ? 'change' : 'add'} image</span>
        </button>

        <div className="space-y-1">
          <label className="text-xs font-medium text-slate-600">Category name</label>
          <input
            value={name}
            onChange={e => setName(e.target.value)}
            placeholder="e.g. Edible Oils"
            className={`w-full px-3.5 py-3 rounded-xl border-2 text-sm focus:ring-2 focus:ring-violet-100 bg-white ${name ? 'border-violet-500' : 'border-slate-200 focus:border-violet-400'}`}
          />
        </div>

        <div className="flex items-start justify-between bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
          <div>
            <p className="text-sm font-semibold text-slate-800">Active</p>
            <p className="text-xs text-slate-400 mt-0.5">Inactive categories stay in your catalog but are hidden from retailers.</p>
          </div>
          <Toggle checked={active} onChange={setActive} />
        </div>

        <button
          onClick={handleSave}
          disabled={!name.trim()}
          className="w-full bg-violet-600 hover:bg-violet-700 disabled:bg-slate-200 disabled:text-slate-400 text-white font-bold py-4 rounded-2xl transition-colors"
        >
          {existing ? 'Save Changes' : 'Add Category'}
        </button>
      </div>
    </div>
  )
}
