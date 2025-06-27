// Environment Configuration
export interface AppConfig {
  API_HOST: string
  API_BASE_URL: string
  APP_TITLE: string
  APP_DESCRIPTION: string
  DEBUG: boolean
  LOG_LEVEL: 'debug' | 'info' | 'warn' | 'error'
  ENABLE_DEV_TOOLS: boolean
  ENABLE_MOCK_API: boolean
}

export const CONFIG: AppConfig = {
  API_HOST: String(import.meta.env.VITE_API_HOST) || 'https://api.realworld.io',
  API_BASE_URL: String(import.meta.env.VITE_API_BASE_URL) || 'https://api.realworld.io/api',
  APP_TITLE: String(import.meta.env.VITE_APP_TITLE) || 'RealWorld',
  APP_DESCRIPTION: String(import.meta.env.VITE_APP_DESCRIPTION) || 'RealWorld example app',
  DEBUG: import.meta.env.VITE_DEBUG === 'true',
  LOG_LEVEL: (import.meta.env.VITE_LOG_LEVEL as AppConfig['LOG_LEVEL']) || 'info',
  ENABLE_DEV_TOOLS: import.meta.env.VITE_ENABLE_DEV_TOOLS === 'true',
  ENABLE_MOCK_API: import.meta.env.VITE_ENABLE_MOCK_API === 'true',
}

// Environment detection
export const ENV = {
  isDevelopment: import.meta.env.DEV,
  isProduction: import.meta.env.PROD,
  mode: import.meta.env.MODE,
}

// API Configuration
export const API_CONFIG = {
  BASE_URL: CONFIG.API_BASE_URL,
  TIMEOUT: 10000, // 10 seconds
  RETRY_ATTEMPTS: 3,
  RETRY_DELAY: 1000, // 1 second
}

// Feature flags
export const FEATURES = {
  DEV_TOOLS: CONFIG.ENABLE_DEV_TOOLS && ENV.isDevelopment,
  MOCK_API: CONFIG.ENABLE_MOCK_API,
  DEBUG_LOGGING: CONFIG.DEBUG && ENV.isDevelopment,
}

// Logging utility
export const logger = {
  debug: (...args: any[]) => {
    if (FEATURES.DEBUG_LOGGING) {
      console.debug('[DEBUG]', ...args)
    }
  },
  info: (...args: any[]) => {
    if (['debug', 'info'].includes(CONFIG.LOG_LEVEL)) {
      console.info('[INFO]', ...args)
    }
  },
  warn: (...args: any[]) => {
    if (['debug', 'info', 'warn'].includes(CONFIG.LOG_LEVEL)) {
      console.warn('[WARN]', ...args)
    }
  },
  error: (...args: any[]) => {
    console.error('[ERROR]', ...args)
  },
}

// Environment-specific settings
if (ENV.isDevelopment) {
  logger.info('Running in development mode')
  logger.debug('API Base URL:', CONFIG.API_BASE_URL)
  logger.debug('Features:', FEATURES)
}
