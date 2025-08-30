import axios from "axios";

// API base URL - nginx에서 프록시 처리
const getApiBaseUrl = () => {
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
