require('dotenv').config();
const express=require('express'),mongoose=require('mongoose'),helmet=require('helmet'),
cors=require('cors'),rateLimit=require('express-rate-limit'),
mongoSanitize=require('express-mongo-sanitize'),compression=require('compression'),
morgan=require('morgan'),path=require('path'),fs=require('fs');
const app=express();
app.use(helmet());
app.use(cors({origin:process.env.ALLOWED_ORIGINS?.split(',')||'*',
  methods:['GET','POST','PUT','PATCH','DELETE'],
  allowedHeaders:['Content-Type','Authorization','X-App-Version','X-Platform']}));
app.use(rateLimit({windowMs:15*60*1000,max:100}));
app.use(express.json({limit:'10mb'}));
app.use(express.urlencoded({extended:true}));
app.use(mongoSanitize());app.use(compression());
if(process.env.NODE_ENV!=='production')app.use(morgan('dev'));
app.disable('x-powered-by');
const uploadsDir=path.join(__dirname,'uploads');
if(!fs.existsSync(uploadsDir))fs.mkdirSync(uploadsDir,{recursive:true});
app.use('/uploads',express.static(uploadsDir));
mongoose.connect(process.env.MONGODB_URI)
  .then(()=>console.log('MongoDB connected'))
  .catch(err=>{console.error(err.message);process.exit(1);});
const {authRoutes,casesRoutes,clientsRoutes,sessionsRoutes,
  invoicesRoutes,documentsRoutes,dashboardRoutes}=require('./routes/index');
app.use('/api/v1/auth',authRoutes);
app.use('/api/v1/cases',casesRoutes);
app.use('/api/v1/clients',clientsRoutes);
app.use('/api/v1/sessions',sessionsRoutes);
app.use('/api/v1/invoices',invoicesRoutes);
app.use('/api/v1/documents',documentsRoutes);
app.use('/api/v1/dashboard',dashboardRoutes);
app.get('/health',(_,res)=>res.json({status:'ok'}));
app.use('*',(_,res)=>res.status(404).json({success:false,message:'not found'}));
app.use((err,req,res,next)=>res.status(500).json({success:false,
  message:process.env.NODE_ENV==='production'?'server error':err.message}));
const PORT=process.env.PORT||5000;
app.listen(PORT,()=>console.log(`Server on port ${PORT}`));
