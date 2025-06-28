import { API_CONFIG, CONFIG, logger } from 'src/config'
import type { GenericErrorModel, HttpResponse } from 'src/services/api'
import { Api, ContentType } from 'src/services/api'

export const limit = 10

// Create API instance with enhanced configuration
export const api = new Api({
  baseUrl: API_CONFIG.BASE_URL,
  securityWorker: token => token ? { headers: { Authorization: `Token ${String(token)}` } } : {},
  baseApiParams: {
    headers: {
      'content-type': ContentType.Json,
      'User-Agent': `${CONFIG.APP_TITLE}/1.0.0`,
    },
    format: 'json',
  },
})

// Add request/response interceptors for logging and error handling
const originalRequest = api.request.bind(api)
api.request = async function<T = any, E = any>(params: any): Promise<HttpResponse<T, E>> {
  const startTime = Date.now()
  
  try {
    logger.debug('API Request:', {
      method: params.method,
      path: params.path,
      query: params.query,
    })
    
    const response = await originalRequest(params)
    
    const duration = Date.now() - startTime
    logger.debug('API Response:', {
      method: params.method,
      path: params.path,
      status: response.status,
      duration: `${duration}ms`,
    })
    
    return response
  } catch (error) {
    const duration = Date.now() - startTime
    logger.error('API Error:', {
      method: params.method,
      path: params.path,
      duration: `${duration}ms`,
      error,
    })
    throw error
  }
}

export function pageToOffset(page: number = 1, localLimit = limit): { limit: number, offset: number } {
  const offset = (page - 1) * localLimit
  return { limit: localLimit, offset }
}

export function isFetchError<E = GenericErrorModel>(e: unknown): e is HttpResponse<unknown, E> {
  return e instanceof Object && 'error' in e
}

// API Health Check utility
export async function checkApiHealth(): Promise<boolean> {
  try {
    const response = await fetch(`${CONFIG.API_HOST}/api/health`)
    return response.ok
  } catch (error) {
    logger.error('API Health check failed:', error)
    return false
  }
}

// Environment-specific API setup
if (CONFIG.DEBUG) {
  logger.info('API initialized:', {
    baseUrl: API_CONFIG.BASE_URL,
    timeout: API_CONFIG.TIMEOUT,
    environment: import.meta.env.MODE,
  })
}
