import axios from "axios";

// Determine API base URL based on environment
const getApiBaseUrl = () => {
  // In Azure Container Apps, use environment variable
  if (import.meta.env.VITE_API_URL) {
    return import.meta.env.VITE_API_URL;
  }
  // For local development, proxy through nginx
  return "/api";
};

const apiClient = axios.create({
  baseURL: getApiBaseUrl(),
  headers: {
    "Content-Type": "application/json",
  },
});

apiClient.interceptors.request.use(
  (config) => {
    const userStr = localStorage.getItem("user");
    if (userStr) {
      try {
        const user = JSON.parse(userStr);
        if (user.userId) {
          config.headers["X-User-ID"] = user.userId;
        }
        if (user.username) {
          config.headers["x-username"] = encodeURIComponent(user.username);
        }
      } catch (error) {
        console.error("Error parsing user information:", error);
      }
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

export default apiClient;
