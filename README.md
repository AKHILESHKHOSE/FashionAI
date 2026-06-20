# 🎨 FashionAI Studio

> An AI-powered fashion design platform with intelligent outfit matching, image similarity search, and sketch-to-design capabilities using advanced machine learning models.

[![Python](https://img.shields.io/badge/Python-3.12+-blue.svg)](https://www.python.org/)
[![Node.js](https://img.shields.io/badge/Node.js-16+-green.svg)](https://nodejs.org/)
[![React](https://img.shields.io/badge/React-18+-61DAFB.svg)](https://reactjs.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-Latest-009688.svg)](https://fastapi.tiangolo.com/)

## ✨ Features

- 🎯 **AI-Powered Design Generation** - Transform sketches into realistic fashion designs
- 🔍 **Intelligent Image Search** - CLIP + FAISS based similarity search
- 👔 **Outfit Matching** - Smart outfit recommendations and compatibility analysis
- 📊 **Trend Analysis** - Real-time fashion trend aggregation
- 👤 **User Management** - Secure authentication and personalization
- 📈 **Analytics Dashboard** - Search analytics and user insights

## 🏗️ Project Structure

```
FashionAIStudio/
├── 📁 project/               # Main application
│   ├── ai_service/          # FastAPI AI service (Python)
│   ├── backend/             # Node.js/Express REST API
│   └── frontend/            # React + TypeScript UI
│
├── 📁 data/                  # Data directory (gitignored)
│   ├── datasets/            # Training/test datasets
│   ├── models/              # Pre-trained AI models
│   └── samples/             # Sample data
│
├── 📁 config/                # Configuration files
│   └── nginx/               # Nginx reverse proxy config
│
├── 📁 scripts/               # Automation scripts
├── 📁 tests/                 # Test suites
│
├── .gitignore
├── docker-compose.yml       # Local development
├── docker-compose.prod.yml  # Production deployment
├── CONTRIBUTING.md
└── README.md
```
├── FRIEND_SETUP.md          # ⭐ Setup guide for new users
└── README.md
```

## 🚀 Quick Start

🌟 **New to this project?** Start with **[FRIEND_SETUP.md](FRIEND_SETUP.md)** for a step-by-step setup guide!

### Prerequisites
- **Node.js** v16+ ([Download](https://nodejs.org/))
- **Python** 3.12+ ([Download](https://www.python.org/))
- **MongoDB** ([Download](https://www.mongodb.com/try/download/community))
- **Git** ([Download](https://git-scm.com/))

### 🎬 Quick Setup

```bash
# Run the setup script
.\scripts\dev\setup_and_start.bat
```

### 📦 Manual Setup

#### 1. AI Service (Python/FastAPI)
```bash
cd project/ai_service
python -m venv .venv
.venv\Scripts\activate  # Windows
# source .venv/bin/activate  # Linux/Mac
pip install -r requirements.txt
python app.py
# Runs on http://localhost:8000
```

If you cannot or prefer not to use Docker, a helper PowerShell script is provided to download Python packages into a local cache (wheels) and clone any git-based dependencies. This lets you fetch required packages beforehand and then install them offline into the virtual environment.

Run from repository root (PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\dev\download_ai_requirements.ps1
```

Then inside project/ai_service activate the venv and install from the cached wheels:

```powershell
cd project/ai_service
.\.venv\Scripts\activate
pip install --no-index --find-links=./wheels -r requirements.txt
```

#### 2. Backend (Node.js/Express)
```bash
cd project/backend
npm install
npm run dev
# Runs on http://localhost:5000
```

#### 3. Frontend (React + Vite)
```bash
cd project/frontend
npm install
npm run dev
# Runs on http://localhost:5173
```

### 🐳 Docker Setup (Recommended)

**Local Development:**
```bash
# 1. Start all services
docker-compose up -d

# 2. Check status
docker-compose ps

# 3. View logs
docker-compose logs -f
```

**Production Deployment:**
```bash
# 1. Copy and configure production environment
cp .env.production.example .env
# Edit .env with strong passwords and your domain

# 2. Set up SSL certificates (see deployment guide)

# 3. Deploy with nginx reverse proxy
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

**Access (Local):**
- 🎨 Frontend: http://localhost:3000
- 🔧 Backend: http://localhost:5000
- 🤖 AI Service: http://localhost:8000/docs
- 🗄️ MongoDB: localhost:27017

**Access (Production):**
- 🌐 Application: https://yourdomain.com
- 📊 Health Check: https://yourdomain.com/health

📖 **Deployment Guide:**
- 🚀 [DEPLOYMENT_GUIDE_HYBRID.md](docs/readmes/DEPLOYMENT_GUIDE_HYBRID.md) - Complete deployment guide (FREE cloud + local AI)

## 📚 Documentation

- 🤝 [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute to this project
- 🚀 [DEPLOYMENT_GUIDE_HYBRID.md](docs/readmes/DEPLOYMENT_GUIDE_HYBRID.md) - Deploy frontend/backend to cloud (FREE)

## 🛠️ Technology Stack

### Frontend
- **React 18** - UI library with hooks
- **TypeScript** - Type-safe development
- **Vite** - Lightning-fast build tool
- **Tailwind CSS** - Utility-first CSS framework
- **Framer Motion** - Smooth animations
- **React Router v7** - Client-side routing
- **Lucide React** - Modern icon library

### Backend
- **Node.js 16+** - JavaScript runtime
- **Express.js** - Minimal web framework
- **MongoDB** - NoSQL database
- **Mongoose** - MongoDB ODM
- **JWT** - Secure authentication
- **Bcrypt** - Password hashing
- **Axios** - HTTP client
- **Express Validator** - Input validation
- **Cookie Parser** - Cookie management

### AI Service
- **Python 3.12+** - Core language
- **FastAPI** - Modern async web framework
- **PyTorch** - Deep learning framework
- **Transformers (CLIP)** - Image-text embeddings
- **FAISS** - Vector similarity search
- **Diffusers** - Stable Diffusion v1.5
- **P  /generate                - Generate fashion design from text/sketch
POST   /search/similar          - CLIP+FAISS similarity search
POST   /outfit/match            - Outfit compatibility analysis
POST   /occasions/generate      - Generate outfit by occasion
GET    /occasions                - List available occasions
POST   /upload                  - Upload and process fashion images
GET    /health                  - Health check endpoint
GET    /                        - Welcome message
```

### Backend API (Port 5000)
```
POST   /api/auth/register       - User registration
POST   /api/auth/login          - User login
POST   /api/auth/logout         - User logout
GET    /api/user/profile        - Get user profile
PUT    /api/user/profile        - Update user profile
POST   /api/ai/*                - Proxy to AI service
GET    /api/analytics/*         - Analytics data
GET    /api/trends/*            - Fashion trend data (Google Trends API)
GET    /api/health              - Backend health check
```

### Frontend (Port 5173)
- Vite dev server with hot module replacement
- Production build served via static hostingT /search/similar     - Find similar images
POST /outfit/match       - Get outfit recommendations
GET  /health            - Service health check
```

### Backend API (Port 5000)
```
POST /api/auth/register  - User registration
POST /api/auth/login     - User login
GET  /api/user/profile   - Get user profile
POST /api/ai/*          - AI service proxy
GET  /api/analytics/*    - Analytics endpoints
GET  /api/trends/*       - Trend data
```

## 🧪 Running Tests

```bash
# AI Service tests
cd project/ai_service
pytest tests/ -v

# Backend tests
cd project/backend
npm test

# Frontend tests
cd project/frontend
npm test
```

## 🛠️ Development Scripts

```bash
# Setup & Verification
python scripts/setup/check_gpu.py           # Check GPU availability
python scripts/setup/verify_setup.py        # Verify installation

```bash
# Setup Scripts (scripts/setup/)
python scripts/setup/check_gpu.py           # Verify CUDA/GPU availability
python scripts/setup/verify_setup.py        # Validate complete installation

# Development Utilities
.\scripts\dev\restart_backend.bat     # Restart backend service
.\scripts\dev\setup_and_start.bat     # Full setup & start all services

# Docker
docker-compose up -d                  # Start all services
docker-compose down                   # Stop all services
docker-compose logs -f                # View logs
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Make changes in the `services/` directory (recommended)
4. Follow the code style and conventions
5. Commit your changes (`git commit -m 'feat: add amazing feature'`)
6. ⚙️ Environment Variables

### AI Service (.env)
```env
ENVIRONMENT=development
HOST=0.0.0.0
PORT=8000
MODEL_CACHE_DIR=./models
```

### Backend (.env)
```env
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb://localhost:27017/fashionai
JWT_SECRET=your-secret-key-here
AI_SERVICE_URL=http://localhost:8000
```

### Frontend (.env)
```env
VITE_API_URL=http://localhost:5000
VITE_AI_SERVICE_URL=http://localhost:8000
```

## 📝 License

This project is proprietary and confidential.

## 👥 Team

- **Sushant Fokmare** - Lead Developer - [@sushantfokmare](https://github.com/sushantfokmare)

## 📞 Support

- 📧 Email: support@fashionai.com
- 🐛 [Report Issues](https://github.com/sushantfokmare/FashionAI/issues)
- 💬 [Discussions](https://github.com/sushantfokmare/FashionAI/discussions)
- 📖 [Documentation](docs/)

## 🙏 Acknowledgments

- **OpenAI CLIP** - Image and text embeddings
- **Meta FAISS** - Efficient similarity search
- **Stability AI** - Stable Diffusion image generation
- **Hugging Face** - Model hosting and Transformers library
- **RunwayML** - Stable Diffusion v1.5
- The amazing open-source community

## 📝 License

This project is licensed under the MIT License.

## 👥 Team

- **Sushant Fokmare** - [@sushantfokmare](https://github.com/sushantfokmare)

## 📞 Support

- 🐛 [Report Issues](https://github.com/sushantfokmare/FashionAI/issues)
- 💬 [Discussions](https://github.com/sushantfokmare/FashionAI/discussions)

## 🙏 Acknowledgments

- OpenAI CLIP for image embeddings
- Facebook FAISS for similarity search  
- Stability AI for Stable Diffusion
- The open-source community

---

**Made with ❤️ by the FashionAI Studio Team**
