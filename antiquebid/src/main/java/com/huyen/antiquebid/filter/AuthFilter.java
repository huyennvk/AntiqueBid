package com.huyen.antiquebid.filter;

import com.huyen.antiquebid.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(filterName = "AuthFilter", urlPatterns = {"/admin/*", "/account", "/watchlist", "/watchlist-toggle", "/kyc", "/orders", "/checkout", "/dispute"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());

        // Check Admin routes
        if (path.startsWith("/admin")) {
            if (currentUser == null) {
                resp.sendRedirect(contextPath + "/login?redirect=" + path);
                return;
            }
            if (!currentUser.isAdmin()) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khu vực Quản trị viên.");
                return;
            }
        }

        // Check Bidder authenticated routes
        if (currentUser == null) {
            resp.sendRedirect(contextPath + "/login?redirect=" + path);
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
