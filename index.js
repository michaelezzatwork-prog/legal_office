// ══════════════════════════════════════════════════════════
// routes/auth.js
// ══════════════════════════════════════════════════════════
const express  = require('express');
const jwt      = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const { User } = require('../models');
const protect  = require('../middleware/auth');

const router = express.Router();

const sign = (id) => jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRE });

// POST /auth/register  (first-time setup only)
router.post('/register', [
  body('name').notEmpty().withMessage('الاسم مطلوب'),
  body('email').isEmail().withMessage('بريد إلكتروني غير صالح'),
  body('password').isLength({ min: 8 }).withMessage('كلمة المرور 8 أحرف على الأقل'),
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ success: false, errors: errors.array() });

  try {
    const exists = await User.findOne({ email: req.body.email });
    if (exists) return res.status(400).json({ success: false, message: 'البريد مسجل مسبقاً' });

    const user = await User.create(req.body);
    res.status(201).json({ success: true, token: sign(user._id), data: { id: user._id, name: user.name, email: user.email } });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// POST /auth/login
router.post('/login', [
  body('email').isEmail(),
  body('password').notEmpty(),
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ success: false, message: 'بيانات غير صالحة' });

  try {
    const user = await User.findOne({ email: req.body.email }).select('+password');
    if (!user || !(await user.matchPassword(req.body.password))) {
      return res.status(401).json({ success: false, message: 'بريد أو كلمة مرور غير صحيحة' });
    }
    if (!user.isActive) return res.status(401).json({ success: false, message: 'الحساب معطّل' });

    res.json({ success: true, token: sign(user._id), data: { id: user._id, name: user.name, role: user.role } });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// POST /auth/change-password
router.post('/change-password', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('+password');
    if (!(await user.matchPassword(req.body.currentPassword))) {
      return res.status(401).json({ success: false, message: 'كلمة المرور الحالية غير صحيحة' });
    }
    user.password = req.body.newPassword;
    await user.save();
    res.json({ success: true, message: 'تم تغيير كلمة المرور' });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

module.exports = router;


// ══════════════════════════════════════════════════════════
// routes/cases.js
// ══════════════════════════════════════════════════════════
const casesRouter = express.Router();
const { Case } = require('../models');

casesRouter.use(protect);

casesRouter.get('/', async (req, res) => {
  try {
    const { status, type, search } = req.query;
    const filter = { createdBy: req.user.id };
    if (status) filter.status = status;
    if (type)   filter.type   = type;
    if (search) filter.$text  = { $search: search };

    const cases = await Case.find(filter)
      .sort({ createdAt: -1 })
      .populate('clientId', 'name phone')
      .lean();

    res.json({ success: true, count: cases.length, data: cases });
  } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});

casesRouter.get('/:id', async (req, res) => {
  try {
    const c = await Case.findById(req.params.id).populate('clientId', 'name phone email');
    if (!c) return res.status(404).json({ success: false, message: 'القضية غير موجودة' });
    res.json({ success: true, data: c });
  } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});

casesRouter.post('/', [
  body('caseNumber').notEmpty().withMessage('رقم القضية مطلوب'),
  body('court').notEmpty().withMessage('المحكمة مطلوبة'),
  body('title').notEmpty().withMessage('موضوع القضية مطلوب'),
  body('type').notEmpty().withMessage('نوع القضية مطلوب'),
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ success: false, errors: errors.array() });
  try {
    const c = await Case.create({ ...req.body, createdBy: req.user.id });
    res.status(201).json({ success: true, data: c });
  } catch (e) { res.status(400).json({ success: false, message: e.message }); }
});

casesRouter.put('/:id', async (req, res) => {
  try {
    const c = await Case.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (!c) return res.status(404).json({ success: false, message: 'القضية غير موجودة' });
    res.json({ success: true, data: c });
  } catch (e) { res.status(400).json({ success: false, message: e.message }); }
});

casesRouter.delete('/:id', async (req, res) => {
  try {
    const c = await Case.findByIdAndDelete(req.params.id);
    if (!c) return res.status(404).json({ success: false, message: 'القضية غير موجودة' });
    res.json({ success: true, message: 'تم حذف القضية' });
  } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});


// ══════════════════════════════════════════════════════════
// routes/clients.js
// ══════════════════════════════════════════════════════════
const clientsRouter = express.Router();
const { Client } = require('../models');

clientsRouter.use(protect);

clientsRouter.get('/', async (req, res) => {
  try {
    const { status, search } = req.query;
    const filter = { createdBy: req.user.id };
    if (status) filter.status = status;
    if (search) filter.$text  = { $search: search };
    const clients = await Client.find(filter).sort({ createdAt: -1 }).lean();
    res.json({ success: true, count: clients.length, data: clients });
  } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});

clientsRouter.post('/', [
  body('name').notEmpty().withMessage('الاسم مطلوب'),
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ success: false, errors: errors.array() });
  try {
    const cl = await Client.create({ ...req.body, createdBy: req.user.id });
    res.status(201).json({ success: true, data: cl });
  } catch (e) { res.status(400).json({ success: false, message: e.message }); }
});

clientsRouter.put('/:id', async (req, res) => {
  try {
    const cl = await Client.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!cl) return res.status(404).json({ success: false, message: 'الموكل غير موجود' });
    res.json({ success: true, data: cl });
  } catch (e) { res.status(400).json({ success: false, message: e.message }); }
});

clientsRouter.delete('/:id', async (req, res) => {
  try {
    await Client.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'تم الحذف' });
  } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});


// ══════════════════════════════════════════════════════════
// routes/sessions.js
// ══════════════════════════════════════════════════════════
const sessionsRouter = express.Router();
const { Session } = require('../models');

sessionsRouter.use(protect);

sessionsRouter.get('/', async (req, res) => {
  try {
    const { status, type, from, to } = req.query;
    const filter = { createdBy: req.user.id };
    if (status) filter.status = status;
    if (type)   filter.type   = type;
    if (from || to) {
      filter.sessionDate = {};
      if (from) filter.sessionDate.$gte = new Date(from);
      if (to)   filter.sessionDate.$lte = new Date(to);
    }
    const sessions = await Session.find(filter).sort({ sessionDate: 1 }).lean();
    res.json({ success: true, count: sessions.length, data: sessions });
  } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});

sessionsRouter.get('/upcoming', async (req, res) => {
  try {
    const sessions = await Session.find({
      createdBy: req.user.id,
      sessionDate: { $gte: new Date() },
      status: 'upcoming',
    }).sort({ sessionDate: 1 }).limit(10).lean();
    res.json({ success: true, data: sessions });
  } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});

sessionsRouter.post('/', [
  body('type').notEmpty(),
  body('title').notEmpty(),
  body('sessionDate').isISO8601(),
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ success: false, errors: errors.array() });
  try {
    const s = await Session.create({ ...req.body, createdBy: req.user.id });

    // Update case nextSession if linked
    if (req.body.caseId) {
      const { Case } = require('../models');
      await Case.findByIdAndUpdate(req.body.caseId, { nextSession: req.body.sessionDate });
    }

    res.status(201).json({ success: true, data: s });
  } catch (e) { res.status(400).json({ success: false, message: e.message }); }
});

sessionsRouter.put('/:id', async (req, res) => {
  try {
    const s = await Session.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!s) return res.status(404).json({ success: false, message: 'الموعد غير موجود' });
    res.json({ success: true, data: s });
  } catch (e) { res.status(400).json({ success: false, message: e.message }); }
});

sessionsRouter.delete('/:id', async (req, res) => {
  try {
    await Session.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'تم الحذف' });
  } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});


// ══════════════════════════════════════════════════════════
// routes/invoices.js
// ══════════════════════════════════════════════════════════
const invoicesRouter = express.Router();
const { Invoice } = require('../models');

invoicesRouter.use(protect);

invoicesRouter.get('/', async (req, res) => {
  try {
    const invoices = await Invoice.find({ createdBy: req.user.id }).sort({ createdAt: -1 }).lean();
    res.json({ success: true, data: invoices });
  } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});

invoicesRouter.get('/summary', async (req, res) => {
  try {
    const result = await Invoice.aggregate([
      { $match: { createdBy: new mongoose.Types.ObjectId(req.user.id) } },
      { $group: {
        _id: null,
        totalAmount:  { $sum: '$amount' },
        totalPaid:    { $sum: '$paidAmount' },
        totalPending: { $sum: { $subtract: ['$amount', '$paidAmount'] } },
        count:        { $sum: 1 },
      }},
    ]);
    const s = result[0] || { totalAmount: 0, totalPaid: 0, totalPending: 0, count: 0 };
    const rate = s.totalAmount > 0 ? (s.totalPaid / s.totalAmount) * 100 : 0;
    res.json({ success: true, data: { ...s, collectionRate: Math.round(rate) } });
  } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});

invoicesRouter.post('/', [
  body('clientName').notEmpty(),
  body('amount').isNumeric().isFloat({ min: 0 }),
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ success: false, errors: errors.array() });
  try {
    const inv = await Invoice.create({ ...req.body, createdBy: req.user.id });
    res.status(201).json({ success: true, data: inv });
  } catch (e) { res.status(400).json({ success: false, message: e.message }); }
});

// PATCH — record a payment
invoicesRouter.patch('/:id/pay', async (req, res) => {
  try {
    const inv = await Invoice.findById(req.params.id);
    if (!inv) return res.status(404).json({ success: false, message: 'الفاتورة غير موجودة' });

    inv.paidAmount = Math.min(inv.amount, inv.paidAmount + Number(req.body.amount));
    await inv.save();
    res.json({ success: true, data: inv });
  } catch (e) { res.status(400).json({ success: false, message: e.message }); }
});

invoicesRouter.put('/:id', async (req, res) => {
  try {
    const inv = await Invoice.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json({ success: true, data: inv });
  } catch (e) { res.status(400).json({ success: false, message: e.message }); }
});

invoicesRouter.delete('/:id', async (req, res) => {
  try {
    await Invoice.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'تم الحذف' });
  } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});


// ══════════════════════════════════════════════════════════
// routes/documents.js
// ══════════════════════════════════════════════════════════
const documentsRouter = express.Router();
const multer  = require('multer');
const path    = require('path');
const { Document } = require('../models');
const mongoose = require('mongoose');

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename:    (req, file, cb) => {
    const ext  = path.extname(file.originalname);
    const name = `doc_${Date.now()}${ext}`;
    cb(null, name);
  },
});
const upload = multer({
  storage,
  limits: { fileSize: 20 * 1024 * 1024 }, // 20MB
  fileFilter: (req, file, cb) => {
    const allowed = ['.pdf', '.doc', '.docx', '.jpg', '.jpeg', '.png'];
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, allowed.includes(ext));
  },
});

documentsRouter.use(protect);

documentsRouter.get('/', async (req, res) => {
  try {
    const docs = await Document.find({ createdBy: req.user.id }).sort({ createdAt: -1 }).lean();
    res.json({ success: true, data: docs });
  } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});

documentsRouter.get('/templates', async (req, res) => {
  try {
    const templates = await Document.find({ isTemplate: true }).lean();
    res.json({ success: true, data: templates });
  } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});

documentsRouter.post('/', upload.single('file'), async (req, res) => {
  try {
    const doc = await Document.create({
      ...req.body,
      filePath: req.file?.path,
      fileSize: req.file?.size,
      mimeType: req.file?.mimetype,
      createdBy: req.user.id,
    });
    res.status(201).json({ success: true, data: doc });
  } catch (e) { res.status(400).json({ success: false, message: e.message }); }
});

documentsRouter.delete('/:id', async (req, res) => {
  try {
    await Document.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'تم الحذف' });
  } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});


// ══════════════════════════════════════════════════════════
// routes/dashboard.js
// ══════════════════════════════════════════════════════════
const dashboardRouter = express.Router();
const { Case: CaseModel, Client: ClientModel, Session: SessionModel, Invoice: InvoiceModel } = require('../models');

dashboardRouter.use(protect);

dashboardRouter.get('/stats', async (req, res) => {
  try {
    const uid = req.user.id;
    const [activeCases, totalCases, totalClients, invoiceAgg] = await Promise.all([
      CaseModel.countDocuments({ createdBy: uid, status: 'active' }),
      CaseModel.countDocuments({ createdBy: uid }),
      ClientModel.countDocuments({ createdBy: uid, status: 'active' }),
      InvoiceModel.aggregate([
        { $match: { createdBy: new mongoose.Types.ObjectId(uid) } },
        { $group: {
          _id: null,
          collected: { $sum: '$paidAmount' },
          pending:   { $sum: { $subtract: ['$amount', '$paidAmount'] } },
          total:     { $sum: '$amount' },
        }},
      ]),
    ]);

    const agg = invoiceAgg[0] || { collected: 0, pending: 0, total: 0 };
    const rate = agg.total > 0 ? (agg.collected / agg.total) * 100 : 0;

    res.json({
      success: true,
      data: {
        activeCases, totalCases, totalClients,
        collectedFees:   agg.collected,
        pendingFees:     agg.pending,
        collectionRate:  Math.round(rate),
      },
    });
  } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});

// Export all routers
module.exports = {
  authRoutes:      router,
  casesRoutes:     casesRouter,
  clientsRoutes:   clientsRouter,
  sessionsRoutes:  sessionsRouter,
  invoicesRoutes:  invoicesRouter,
  documentsRoutes: documentsRouter,
  dashboardRoutes: dashboardRouter,
};
