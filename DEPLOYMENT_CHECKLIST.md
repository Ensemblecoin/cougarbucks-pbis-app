# 🚀 CougarBucks Deployment Checklist

Use this checklist to ensure a successful deployment of your CougarBucks PBIS application.

## ✅ Pre-Deployment Checklist

### 1. Environment Setup
- [ ] Node.js 18+ installed
- [ ] npm or yarn package manager available
- [ ] Git repository access configured
- [ ] Domain name registered (if applicable)

### 2. Google OAuth Configuration
- [ ] Google Cloud Console project created
- [ ] Google+ API enabled
- [ ] OAuth 2.0 credentials created
- [ ] Production domain added to authorized origins
- [ ] Callback URL configured: `https://your-domain.com/api/auth/callback/google`
- [ ] Client ID and Secret obtained

### 3. Environment Variables
- [ ] `.env.production` file created from template
- [ ] `NEXTAUTH_SECRET` generated (use: `openssl rand -base64 32`)
- [ ] `NEXTAUTH_URL` set to production domain
- [ ] `GOOGLE_CLIENT_ID` configured
- [ ] `GOOGLE_CLIENT_SECRET` configured
- [ ] Optional variables configured (blockchain, database, etc.)

### 4. Code Quality
- [ ] All code committed to version control
- [ ] Linting passes: `npm run lint`
- [ ] Build succeeds: `npm run build`
- [ ] No TypeScript errors
- [ ] All API endpoints tested locally

## 🏗️ Deployment Options

Choose one deployment method:

### Option A: Vercel (Recommended for beginners)
- [ ] Vercel account created
- [ ] Repository connected to Vercel
- [ ] Environment variables configured in Vercel dashboard
- [ ] Domain configured (if custom domain)
- [ ] Deployment successful
- [ ] SSL certificate automatically configured

### Option B: Self-Hosted with PM2
- [ ] Server/VPS provisioned
- [ ] Node.js 18+ installed on server
- [ ] PM2 installed globally: `npm install -g pm2`
- [ ] Code deployed to server
- [ ] Environment variables configured
- [ ] Application started with PM2
- [ ] PM2 configured for auto-restart: `pm2 startup`
- [ ] Nginx configured as reverse proxy (optional)
- [ ] SSL certificate configured (Let's Encrypt recommended)

### Option C: Docker Deployment
- [ ] Docker installed on target system
- [ ] Dockerfile tested locally
- [ ] Environment variables configured
- [ ] Docker image built successfully
- [ ] Container running and accessible
- [ ] Health checks passing
- [ ] Persistent storage configured (if needed)

### Option D: Docker Compose
- [ ] Docker and Docker Compose installed
- [ ] `docker-compose.yml` configured
- [ ] Environment variables set
- [ ] Services started: `docker compose up -d`
- [ ] All containers healthy
- [ ] Nginx proxy configured (if using)

## 🧪 Post-Deployment Testing

### 1. Basic Functionality
- [ ] Application loads at production URL
- [ ] Health check endpoint responds: `/api/health`
- [ ] Google OAuth login works
- [ ] All pages accessible (teacher, student, admin, manage)

### 2. API Endpoints Testing
```bash
# Test token awarding
curl -X POST https://your-domain.com/api/award-token \
  -H "Content-Type: application/json" \
  -d '{"teacherId": "t1", "studentId": "s1", "amount": 5, "criteria": "Test"}'

# Test blockchain ledger
curl -X GET https://your-domain.com/api/blockchain-ledger?analytics=true

# Test student data
curl -X GET https://your-domain.com/api/students?type=students

# Test data management
curl -X POST https://your-domain.com/api/manage-data \
  -H "Content-Type: application/json" \
  -d '{"action": "add", "type": "student", "name": "Test Student", "grade": "10th Grade"}'
```

- [ ] Token awarding API works
- [ ] Blockchain ledger API responds
- [ ] Student data API works
- [ ] Data management API functions
- [ ] All APIs return proper HTTP status codes
- [ ] Error handling works correctly

### 3. User Interface Testing
- [ ] Landing page displays correctly
- [ ] Teacher dashboard functions (award tokens)
- [ ] Student dashboard shows wallet and transactions
- [ ] Admin dashboard displays blockchain ledger
- [ ] Data management interface works (CRUD operations)
- [ ] Responsive design works on mobile
- [ ] All forms validate properly
- [ ] Navigation works correctly

### 4. Performance Testing
- [ ] Page load times acceptable (< 3 seconds)
- [ ] API response times reasonable (< 1 second)
- [ ] Images load and display properly
- [ ] No console errors in browser
- [ ] Memory usage stable
- [ ] No memory leaks detected

### 5. Security Testing
- [ ] HTTPS enabled and working
- [ ] Security headers present
- [ ] OAuth flow secure
- [ ] API endpoints protected appropriately
- [ ] No sensitive data exposed in client
- [ ] Environment variables not exposed

## 🔧 Configuration Verification

### 1. Next.js Configuration
- [ ] `next.config.ts` optimized for production
- [ ] Image optimization configured
- [ ] Security headers enabled
- [ ] Compression enabled
- [ ] Caching headers configured

### 2. Server Configuration
- [ ] Reverse proxy configured (if applicable)
- [ ] SSL/TLS certificates valid
- [ ] Firewall rules configured
- [ ] Rate limiting enabled (if applicable)
- [ ] Monitoring configured

### 3. Database/Storage
- [ ] Data persistence working
- [ ] Backup strategy implemented (if applicable)
- [ ] Connection pooling configured (if applicable)

## 📊 Monitoring Setup

### 1. Application Monitoring
- [ ] Health check endpoint monitored
- [ ] Application logs configured
- [ ] Error tracking setup (Sentry, etc.)
- [ ] Performance monitoring enabled
- [ ] Uptime monitoring configured

### 2. Infrastructure Monitoring
- [ ] Server resources monitored (CPU, memory, disk)
- [ ] Network connectivity monitored
- [ ] SSL certificate expiration monitoring
- [ ] Backup verification automated

## 🚨 Troubleshooting

### Common Issues and Solutions

#### Build Failures
- [ ] Check Node.js version (must be 18+)
- [ ] Clear `.next` folder and rebuild
- [ ] Verify all dependencies installed
- [ ] Check for TypeScript errors

#### OAuth Issues
- [ ] Verify Google OAuth credentials
- [ ] Check authorized domains in Google Console
- [ ] Ensure callback URL is correct
- [ ] Verify `NEXTAUTH_URL` matches domain

#### API Errors
- [ ] Check server logs for detailed errors
- [ ] Verify environment variables are set
- [ ] Test API endpoints individually
- [ ] Check network connectivity

#### Performance Issues
- [ ] Enable Next.js caching
- [ ] Optimize images and assets
- [ ] Use CDN for static assets
- [ ] Check database query performance

## 📋 Go-Live Checklist

### Final Steps Before Going Live
- [ ] All tests passing
- [ ] Performance acceptable
- [ ] Security verified
- [ ] Monitoring configured
- [ ] Backup strategy in place
- [ ] Documentation updated
- [ ] Team trained on deployment
- [ ] Rollback plan prepared

### Post Go-Live
- [ ] Monitor application for first 24 hours
- [ ] Check error logs regularly
- [ ] Verify user feedback
- [ ] Monitor performance metrics
- [ ] Schedule regular maintenance

## 📞 Support Contacts

- **Technical Issues**: Check `deployment-guide.md`
- **Application Issues**: Review `README.md`
- **Emergency Contacts**: [Add your team contacts here]

---

## 🎉 Deployment Complete!

Once all items are checked off, your CougarBucks application should be successfully deployed and ready for production use.

**Remember to:**
- Keep environment variables secure
- Monitor application health regularly
- Update dependencies periodically
- Backup data regularly
- Review security settings quarterly

**Congratulations on your successful deployment! 🚀**
