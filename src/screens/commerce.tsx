import { useState } from 'react'
import { useApp } from '../context'
import { products, categories } from '../data'
import { BackButton } from '../components'
import type { Order } from '../types'

// ─── Cart ─────────────────────────────────────────────────────────────────────

export function Cart() {
  const { cart, updateQty, removeFromCart, navigate, clearCart } = useApp()

  const items = cart.map(ci => {
    const product = products.find(p => p.id === ci.productId)!
    return { ...ci, product }
  }).filter(i => i.product)

  const subtotal = items.reduce((s, i) => s + i.product.price * i.qty, 0)
  const deliveryCharge = 80
  const minOrder = 5000
  const remaining = Math.max(0, minOrder - subtotal)

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-3 flex items-center gap-3 border-b border-slate-100">
        <BackButton />
        <h1 className="text-lg font-bold text-slate-900">Cart</h1>
        {items.length > 0 && (
          <button onClick={clearCart} className="ml-auto text-xs text-red-500 font-medium">Clear all</button>
        )}
      </div>

      {items.length === 0 ? (
        <div className="flex-1 flex flex-col items-center justify-center gap-4">
          <span className="text-6xl">🛒</span>
          <div className="text-center">
            <p className="text-slate-700 font-semibold">Your cart is empty</p>
            <p className="text-slate-400 text-sm mt-1">Add products to place a wholesale order</p>
          </div>
          <button onClick={() => navigate('home')} className="bg-violet-600 text-white px-6 py-3 rounded-xl font-semibold">Browse Products</button>
        </div>
      ) : (
        <>
          <div className="flex-1 overflow-y-auto no-scrollbar">
            <div className="p-4 space-y-3">
              {items.map(item => {
                const cat = categories.find(c => c.id === item.product.categoryId)
                return (
                  <div key={item.productId} className="bg-white rounded-2xl p-3.5 flex items-center gap-3 border border-slate-100 shadow-sm">
                    <div
                      className="w-14 h-14 rounded-xl flex items-center justify-center text-2xl flex-shrink-0"
                      style={{ backgroundColor: (cat?.bgColor ?? '#7C3AED') + '18' }}
                    >
                      {item.product.emoji}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-semibold text-slate-800 truncate">{item.product.name}</p>
                      <p className="text-xs text-slate-400">{item.qty} {item.product.unit} @ ₹{item.product.price}/{item.product.unit}</p>
                      <p className="text-sm font-bold text-violet-600">₹{(item.product.price * item.qty).toLocaleString('en-IN')}</p>
                    </div>
                    <div className="flex flex-col items-end gap-2">
                      <button onClick={() => removeFromCart(item.productId)} className="text-lg text-red-400 hover:text-red-600">🗑</button>
                      <div className="flex items-center gap-1.5 bg-slate-100 rounded-lg px-1.5 py-1">
                        <button onClick={() => updateQty(item.productId, item.qty - 1)} className="w-6 h-6 flex items-center justify-center text-slate-600 font-bold hover:bg-slate-200 rounded">−</button>
                        <span className="text-sm font-bold text-slate-900 w-6 text-center">{item.qty}</span>
                        <button onClick={() => updateQty(item.productId, item.qty + 1)} className="w-6 h-6 flex items-center justify-center text-slate-600 font-bold hover:bg-slate-200 rounded">+</button>
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>

            {/* Min order warning */}
            {remaining > 0 && (
              <div className="mx-4 mb-4 bg-amber-50 border border-amber-200 rounded-xl px-4 py-3 text-sm text-amber-700">
                Add <span className="font-bold">₹{remaining.toLocaleString('en-IN')}</span> more to reach the ₹5,000 minimum order.
              </div>
            )}

            {/* Summary */}
            <div className="mx-4 mb-4 bg-white rounded-2xl p-4 border border-slate-100 shadow-sm space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-slate-500">Subtotal ({items.reduce((s, i) => s + i.qty, 0)} items)</span>
                <span className="font-semibold text-slate-900">₹{subtotal.toLocaleString('en-IN')}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-slate-500">Delivery Charge</span>
                <span className="font-semibold text-slate-900">₹{deliveryCharge}</span>
              </div>
              <div className="border-t border-slate-100 pt-2 flex justify-between">
                <span className="font-bold text-slate-900">Total</span>
                <span className="font-bold text-slate-900">₹{(subtotal + deliveryCharge).toLocaleString('en-IN')}</span>
              </div>
            </div>
          </div>

          <div className="px-4 pb-4 pt-2 bg-white border-t border-slate-100">
            <button
              onClick={() => navigate('checkout')}
              disabled={remaining > 0}
              className="w-full bg-violet-600 hover:bg-violet-700 disabled:bg-slate-200 disabled:text-slate-400 text-white font-bold py-4 rounded-2xl transition-colors text-base"
            >
              Proceed to Checkout →
            </button>
            {remaining > 0 && <p className="text-center text-xs text-slate-400 mt-2">Add ₹{remaining.toLocaleString('en-IN')} more to unlock checkout</p>}
          </div>
        </>
      )}
    </div>
  )
}

// ─── Checkout ─────────────────────────────────────────────────────────────────

export function Checkout() {
  const { cart, navigate, placeOrder, setLastOrderId, clearCart } = useApp()
  const [address, setAddress] = useState({ street: 'MG Road, Shop No. 14', city: 'Pune', pincode: '411001' })
  const [payment, setPayment] = useState<'cod' | 'upi'>('cod')
  const [loading, setLoading] = useState(false)

  const items = cart.map(ci => {
    const product = products.find(p => p.id === ci.productId)!
    return { ...ci, product }
  }).filter(i => i.product)

  const subtotal = items.reduce((s, i) => s + i.product.price * i.qty, 0)
  const deliveryCharge = 80
  const total = subtotal + deliveryCharge

  const handlePlaceOrder = () => {
    setLoading(true)
    const orderId = Math.random().toString(16).slice(2, 8).toUpperCase()

    setTimeout(() => {
      if (payment === 'upi') {
        navigate('upi', { orderId, total })
        setLoading(false)
      } else {
        const newOrder: Order = {
          id: orderId,
          retailerId: 'sharma',
          retailerName: 'Sharma General Store',
          items: items.map(i => ({
            productId: i.productId,
            name: i.product.name,
            qty: i.qty,
            unit: i.product.unit,
            unitPrice: i.product.price,
            total: i.product.price * i.qty,
          })),
          subtotal,
          deliveryCharge,
          total,
          status: 'pending',
          date: new Date().toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' }),
          address: `${address.street}, ${address.city}, ${address.pincode}`,
          payment: 'Cash on Delivery',
          paid: false,
        }
        placeOrder(newOrder)
        setLastOrderId(orderId)
        clearCart()
        navigate('order-success')
        setLoading(false)
      }
    }, 800)
  }

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-3 flex items-center gap-3 border-b border-slate-100">
        <BackButton />
        <h1 className="text-lg font-bold text-slate-900">Checkout</h1>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-4">
        {/* Delivery address */}
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm space-y-3">
          <h2 className="text-base font-bold text-slate-900">Delivery Address</h2>
          <div className="space-y-2">
            <div className="space-y-1">
              <label className="text-xs text-slate-500 font-medium">Street Address</label>
              <div className="relative">
                <span className="absolute left-3 top-3 text-sm">🏠</span>
                <input
                  value={address.street}
                  onChange={e => setAddress(a => ({ ...a, street: e.target.value }))}
                  className="w-full pl-8 pr-3 py-2.5 border border-slate-200 rounded-xl text-sm focus:border-violet-400 focus:ring-2 focus:ring-violet-100"
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-2">
              <div className="space-y-1">
                <label className="text-xs text-slate-500 font-medium">City</label>
                <input value={address.city} onChange={e => setAddress(a => ({ ...a, city: e.target.value }))} className="w-full px-3 py-2.5 border border-slate-200 rounded-xl text-sm focus:border-violet-400" />
              </div>
              <div className="space-y-1">
                <label className="text-xs text-slate-500 font-medium">Pincode</label>
                <input value={address.pincode} onChange={e => setAddress(a => ({ ...a, pincode: e.target.value }))} className="w-full px-3 py-2.5 border border-slate-200 rounded-xl text-sm focus:border-violet-400" />
              </div>
            </div>
          </div>
          <p className="text-xs text-emerald-600 font-medium">✓ Detected: {address.street}, {address.city}, {address.pincode}
            <button className="text-violet-600 ml-2">Refresh location</button>
          </p>
        </div>

        {/* Payment method */}
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm space-y-2">
          <h2 className="text-base font-bold text-slate-900">Payment Method</h2>
          {[
            { value: 'cod' as const, label: '💵 Cash on Delivery (COD)' },
            { value: 'upi' as const, label: '📱 UPI' },
          ].map(opt => (
            <label key={opt.value} className={`flex items-center gap-3 p-3 rounded-xl border-2 cursor-pointer transition-colors ${payment === opt.value ? 'border-violet-500 bg-violet-50' : 'border-slate-100 hover:border-slate-200'}`}>
              <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center flex-shrink-0 ${payment === opt.value ? 'border-violet-500' : 'border-slate-300'}`}>
                {payment === opt.value && <div className="w-2.5 h-2.5 rounded-full bg-violet-500" />}
              </div>
              <input type="radio" className="sr-only" checked={payment === opt.value} onChange={() => setPayment(opt.value)} />
              <span className="text-sm font-medium text-slate-800">{opt.label}</span>
            </label>
          ))}
        </div>

        {/* Order summary */}
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm space-y-2">
          <h2 className="text-base font-bold text-slate-900">Order Summary</h2>
          <div className="flex justify-between text-sm">
            <span className="text-slate-500">Subtotal ({items.reduce((s, i) => s + i.qty, 0)} items)</span>
            <span className="font-medium">₹{subtotal.toLocaleString('en-IN')}</span>
          </div>
          <div className="flex justify-between text-sm">
            <span className="text-slate-500">Delivery Charge</span>
            <span className="font-medium">₹{deliveryCharge}</span>
          </div>
          <div className="border-t border-slate-100 pt-2 flex justify-between font-bold text-slate-900">
            <span>Grand Total</span>
            <span>₹{total.toLocaleString('en-IN')}</span>
          </div>
        </div>
      </div>

      <div className="px-4 pb-4 pt-2 bg-white border-t border-slate-100">
        <button
          onClick={handlePlaceOrder}
          disabled={loading}
          className="w-full bg-violet-600 hover:bg-violet-700 text-white font-bold py-4 rounded-2xl transition-colors text-base flex items-center justify-center gap-2 disabled:opacity-70"
        >
          {loading
            ? <><span className="w-5 h-5 rounded-full border-2 border-violet-300 spin border-t-white" />Placing…</>
            : '✓ Place Order'
          }
        </button>
      </div>
    </div>
  )
}

// ─── UPI Payment ──────────────────────────────────────────────────────────────

export function UPIPayment() {
  const { params, navigate, cart, placeOrder, setLastOrderId, clearCart } = useApp()
  const total = params.total as number ?? 0
  const orderId = params.orderId as string ?? 'NEW'
  const [uploaded, setUploaded] = useState(false)
  const [loading, setLoading] = useState(false)
  const [copied, setCopied] = useState(false)

  const QR_PATTERN = [
    [1,1,1,1,1,1,1,0,1,0,1,1,0,1,1,1,1,1,1,1,1],
    [1,0,0,0,0,0,1,0,1,1,0,0,1,0,1,0,0,0,0,0,1],
    [1,0,1,1,1,0,1,0,0,1,1,1,0,1,0,1,1,1,0,0,1],
    [1,0,1,1,1,0,1,0,1,0,1,0,0,1,0,1,1,1,0,0,1],
    [1,0,1,1,1,0,1,0,0,1,0,1,1,0,0,1,1,1,0,0,1],
    [1,0,0,0,0,0,1,0,1,0,1,1,0,0,0,0,0,0,0,0,1],
    [1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1],
    [0,0,0,0,0,0,0,0,0,1,1,0,1,0,0,0,0,0,0,0,0],
    [1,0,1,1,0,1,1,1,0,1,0,1,1,0,1,0,1,1,0,1,0],
    [0,1,1,0,1,0,0,1,1,0,1,1,0,0,1,1,0,1,1,0,1],
    [1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1,1,0,0,1,0],
    [0,1,0,0,1,1,0,1,0,1,0,1,1,0,1,0,0,1,0,0,1],
    [1,1,0,1,0,0,1,0,1,0,1,1,0,1,0,1,1,0,1,1,0],
    [0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,1,1,0,1,0,1],
    [1,1,1,1,1,1,1,0,0,1,1,0,1,0,1,0,1,0,0,0,0],
    [1,0,0,0,0,0,1,0,1,1,0,0,1,0,0,1,0,1,1,0,1],
    [1,0,1,1,1,0,1,0,0,1,1,0,0,1,1,0,1,0,0,1,0],
    [1,0,1,1,1,0,1,0,1,0,0,1,0,0,1,1,0,0,1,0,1],
    [1,0,1,1,1,0,1,0,1,1,0,1,1,0,0,1,0,1,0,1,0],
    [1,0,0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1],
    [1,1,1,1,1,1,1,0,1,0,1,1,0,0,0,1,0,0,1,1,0],
  ]

  const handleCopy = () => {
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  const handlePaid = () => {
    setLoading(true)
    const items = cart.map(ci => {
      const product = products.find(p => p.id === ci.productId)!
      return { productId: ci.productId, name: product.name, qty: ci.qty, unit: product.unit, unitPrice: product.price, total: product.price * ci.qty }
    })
    const subtotal = items.reduce((s, i) => s + i.total, 0)
    const order: Order = {
      id: orderId,
      retailerId: 'sharma',
      retailerName: 'Sharma General Store',
      items,
      subtotal,
      deliveryCharge: 80,
      total: subtotal + 80,
      status: 'pending',
      date: new Date().toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' }),
      address: 'MG Road, Shop No. 14, Pune, 411001',
      payment: 'UPI',
      paid: false,
    }
    setTimeout(() => {
      placeOrder(order)
      setLastOrderId(orderId)
      clearCart()
      navigate('order-success')
      setLoading(false)
    }, 1000)
  }

  return (
    <div className="flex-1 flex flex-col min-h-0 bg-slate-50">
      <div className="bg-white px-4 pt-4 pb-3 flex items-center gap-3 border-b border-slate-100">
        <BackButton />
        <h1 className="text-lg font-bold text-slate-900">UPI Payment</h1>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar p-5 space-y-5">
        <div className="text-center">
          <p className="text-2xl font-extrabold text-slate-900">Pay ₹{total.toLocaleString('en-IN')}</p>
          <p className="text-sm text-slate-400 mt-1">Scan with any UPI app, or use the ID below</p>
        </div>

        {/* QR Code */}
        <div className="flex justify-center">
          <div className="bg-white border-2 border-violet-400 rounded-2xl p-4 shadow-sm">
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(21, 10px)', gap: '1px' }}>
              {QR_PATTERN.flat().map((cell, i) => (
                <div key={i} style={{ width: 10, height: 10, backgroundColor: cell ? '#0f172a' : 'white' }} />
              ))}
            </div>
          </div>
        </div>

        {/* UPI ID */}
        <div className="bg-white rounded-xl border border-slate-200 px-4 py-3 flex items-center justify-between">
          <span className="text-sm text-slate-700 font-medium">jyotitraders@okhdfcbank</span>
          <button onClick={handleCopy} className="text-slate-400 hover:text-violet-600 transition-colors">
            {copied ? '✓' : '📋'}
          </button>
        </div>

        {/* Screenshot upload */}
        <div className="space-y-2">
          <p className="text-sm font-semibold text-slate-900">Payment Screenshot <span className="text-slate-400 font-normal">(optional)</span></p>
          <button
            onClick={() => setUploaded(true)}
            className={`w-full border-2 border-dashed rounded-xl py-6 text-sm font-medium transition-colors ${uploaded ? 'border-emerald-400 bg-emerald-50 text-emerald-600' : 'border-slate-200 text-slate-400 hover:border-violet-400 hover:text-violet-500'}`}
          >
            {uploaded ? '✓ Screenshot uploaded' : '↑ Tap to upload screenshot'}
          </button>
        </div>
      </div>

      <div className="px-4 pb-4 pt-2 bg-white border-t border-slate-100 space-y-2">
        <button
          onClick={handlePaid}
          disabled={loading}
          className="w-full bg-violet-600 hover:bg-violet-700 text-white font-bold py-4 rounded-2xl transition-colors flex items-center justify-center gap-2 disabled:opacity-70"
        >
          {loading ? <span className="w-5 h-5 rounded-full border-2 border-violet-300 spin border-t-white" /> : '✓ I Have Paid'}
        </button>
        <p className="text-center text-xs text-slate-400">The admin will confirm your payment shortly after.</p>
      </div>
    </div>
  )
}

// ─── Order Success ────────────────────────────────────────────────────────────

export function OrderSuccess() {
  const { lastOrderId, navigate } = useApp()

  return (
    <div className="flex-1 flex flex-col items-center justify-center bg-white px-6 gap-6">
      <div className="scale-in flex flex-col items-center gap-4 text-center">
        <div className="w-24 h-24 bg-emerald-100 rounded-full flex items-center justify-center">
          <span className="text-5xl">✅</span>
        </div>
        <div>
          <h2 className="text-2xl font-extrabold text-slate-900">Order Placed!</h2>
          <p className="text-violet-600 font-medium mt-1">Order #{lastOrderId}</p>
          <p className="text-slate-400 text-sm mt-2 leading-relaxed">
            The admin has been notified and will confirm your order shortly.
          </p>
        </div>
      </div>

      <div className="w-full space-y-3">
        <button
          onClick={() => navigate('order-detail', { orderId: lastOrderId })}
          className="w-full bg-violet-600 hover:bg-violet-700 text-white font-bold py-4 rounded-2xl transition-colors"
        >
          View Order
        </button>
        <button
          onClick={() => navigate('home')}
          className="w-full text-violet-600 font-semibold py-3 rounded-2xl hover:bg-violet-50 transition-colors"
        >
          Continue Shopping
        </button>
      </div>
    </div>
  )
}
