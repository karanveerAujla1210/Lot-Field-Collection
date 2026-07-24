'use client'

import { useState, useCallback } from 'react'

interface GeolocationState {
  latitude: number | null
  longitude: number | null
  error: string | null
  isLoading: boolean
}

export function useGeolocation() {
  const [state, setState] = useState<GeolocationState>({
    latitude: null,
    longitude: null,
    error: null,
    isLoading: false,
  })

  const getCurrentPosition = useCallback((): Promise<GeolocationCoordinates> => {
    return new Promise((resolve, reject) => {
      if (!navigator.geolocation) {
        reject(new Error('Geolocation is not supported by this browser'))
        return
      }
      setState((prev) => ({ ...prev, isLoading: true, error: null }))
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setState({
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
            error: null,
            isLoading: false,
          })
          resolve(position.coords)
        },
        (err) => {
          const msg = err.message ?? 'Unable to retrieve location'
          setState((prev) => ({ ...prev, error: msg, isLoading: false }))
          reject(new Error(msg))
        },
        { enableHighAccuracy: true, timeout: 10000 }
      )
    })
  }, [])

  return { ...state, getCurrentPosition }
}
