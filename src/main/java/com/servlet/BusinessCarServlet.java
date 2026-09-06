package com.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Handles all Manage Cars operations for the Business Partner module.
 *
 * URL: /BusinessCar
 *
 * Supported actions (request parameter "action"):
 *   GET  list    — forward to manage-cars.jsp with car list
 *   GET  edit    — forward to manage-cars.jsp in edit mode with car pre-filled
 *   POST add     — insert a new car, redirect back to list
 *   POST update  — update an existing car, redirect back to list
 *   POST toggle  — toggle AVAILABLE ↔ INACTIVE, redirect back to list
 *   POST delete  — delete a car (guards against active bookings), redirect back
 *
 * Auth: every path validates BUSINESS_ID + USER_ROLE == "BUSINESS_PARTNER" from session.
 * The businessId from session is always used for DB queries — never from request params.
 */
@WebServlet("/BusinessCar")
public class BusinessCarServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // -----------------------------------------------------------------------
    // GET — list or edit
    // -----------------------------------------------------------------------

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String businessId = getAuthenticatedBusinessId(req, res);
        if (businessId == null) return; // auth guard redirected

        String action = req.getParameter("action");

        try {
            BusinessDAO dao = new BusinessDAO();

            if ("edit".equals(action)) {
                // Load the specific car for editing
                String carId = req.getParameter("carId");
                if (carId == null || carId.trim().isEmpty()) {
                    res.sendRedirect("BusinessCar?action=list");
                    return;
                }
                BusinessCarBean car = dao.getCarById(carId.trim(), businessId);
                if (car == null) {
                    req.setAttribute("error", "Car not found or access denied.");
                    forwardToList(req, res, dao, businessId);
                    return;
                }
                req.setAttribute("editCar", car);
                req.setAttribute("cars", dao.getCarsByBusiness(businessId));
                req.setAttribute("mode", "edit");
                req.getRequestDispatcher("manage-cars.jsp").forward(req, res);

            } else {
                // Default: list
                forwardToList(req, res, dao, businessId);
            }

        } catch (Exception e) {
            req.setAttribute("error", "Failed to load cars: " + e.getMessage());
            req.getRequestDispatcher("manage-cars.jsp").forward(req, res);
        }
    }

    // -----------------------------------------------------------------------
    // POST — add / update / toggle / delete
    // -----------------------------------------------------------------------

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String businessId = getAuthenticatedBusinessId(req, res);
        if (businessId == null) return;

        String action = req.getParameter("action");
        BusinessDAO dao = new BusinessDAO();

        try {
            switch (action == null ? "" : action) {

                case "add":
                    handleAdd(req, res, dao, businessId);
                    break;

                case "update":
                    handleUpdate(req, res, dao, businessId);
                    break;

                case "toggle":
                    handleToggle(req, res, dao, businessId);
                    break;

                case "delete":
                    handleDelete(req, res, dao, businessId);
                    break;

                default:
                    res.sendRedirect("BusinessCar?action=list");
            }
        } catch (Exception e) {
            req.setAttribute("error", "An unexpected error occurred: " + e.getMessage());
            try {
                req.setAttribute("cars", dao.getCarsByBusiness(businessId));
            } catch (Exception ignored) {}
            req.getRequestDispatcher("manage-cars.jsp").forward(req, res);
        }
    }

    // -----------------------------------------------------------------------
    // Action handlers
    // -----------------------------------------------------------------------

    private void handleAdd(HttpServletRequest req, HttpServletResponse res,
                           BusinessDAO dao, String businessId)
            throws Exception, IOException, ServletException {

        BusinessCarBean c = buildBeanFromRequest(req, businessId);
        String validationError = validate(c);
        if (validationError != null) {
            req.setAttribute("error", validationError);
            req.setAttribute("formCar", c);
            req.setAttribute("mode", "add");
            req.setAttribute("cars", dao.getCarsByBusiness(businessId));
            req.getRequestDispatcher("manage-cars.jsp").forward(req, res);
            return;
        }

        try {
            dao.addCar(c);
            res.sendRedirect("BusinessCar?action=list&success=Car+registered+successfully.");
        } catch (BusinessDAO.DuplicateRegistrationException e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("formCar", c);
            req.setAttribute("mode", "add");
            req.setAttribute("cars", dao.getCarsByBusiness(businessId));
            req.getRequestDispatcher("manage-cars.jsp").forward(req, res);
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse res,
                              BusinessDAO dao, String businessId)
            throws Exception, IOException, ServletException {

        String carId = req.getParameter("carId");
        if (blank(carId)) {
            res.sendRedirect("BusinessCar?action=list");
            return;
        }

        BusinessCarBean c = buildBeanFromRequest(req, businessId);
        c.setCarId(carId.trim());

        String validationError = validate(c);
        if (validationError != null) {
            req.setAttribute("error", validationError);
            req.setAttribute("editCar", c);
            req.setAttribute("mode", "edit");
            req.setAttribute("cars", dao.getCarsByBusiness(businessId));
            req.getRequestDispatcher("manage-cars.jsp").forward(req, res);
            return;
        }

        boolean updated = dao.updateCar(c, businessId);
        if (updated) {
            res.sendRedirect("BusinessCar?action=list&success=Car+updated+successfully.");
        } else {
            req.setAttribute("error", "Car not found or you do not have permission to edit it.");
            forwardToList(req, res, dao, businessId);
        }
    }

    private void handleToggle(HttpServletRequest req, HttpServletResponse res,
                              BusinessDAO dao, String businessId)
            throws Exception, IOException, ServletException {

        String carId = req.getParameter("carId");
        if (blank(carId)) {
            res.sendRedirect("BusinessCar?action=list");
            return;
        }

        String newStatus = dao.toggleCarAvailability(carId.trim(), businessId);
        if (newStatus != null) {
            res.sendRedirect("BusinessCar?action=list&success=Car+status+changed+to+"
                + newStatus + ".");
        } else {
            req.setAttribute("error",
                "Cannot toggle status. Car may be BOOKED or under MAINTENANCE.");
            forwardToList(req, res, dao, businessId);
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse res,
                              BusinessDAO dao, String businessId)
            throws Exception, IOException, ServletException {

        String carId = req.getParameter("carId");
        if (blank(carId)) {
            res.sendRedirect("BusinessCar?action=list");
            return;
        }

        try {
            boolean deleted = dao.deleteCar(carId.trim(), businessId);
            if (deleted) {
                res.sendRedirect("BusinessCar?action=list&success=Car+deleted+successfully.");
            } else {
                req.setAttribute("error", "Car not found or you do not have permission to delete it.");
                forwardToList(req, res, dao, businessId);
            }
        } catch (BusinessDAO.CarHasActiveBookingsException e) {
            req.setAttribute("error", e.getMessage());
            forwardToList(req, res, dao, businessId);
        }
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    /** Builds a BusinessCarBean from POST parameters. businessId is always from session. */
    private BusinessCarBean buildBeanFromRequest(HttpServletRequest req, String businessId) {
        BusinessCarBean c = new BusinessCarBean();
        c.setBusinessId(businessId);
        c.setRegistrationNumber(trim(req.getParameter("registrationNumber")));
        c.setCarName(trim(req.getParameter("carName")));
        c.setBrand(trim(req.getParameter("brand")));
        c.setModel(trim(req.getParameter("model")));
        c.setBodyType(trim(req.getParameter("bodyType")));
        c.setFuelType(trim(req.getParameter("fuelType")));
        c.setTransmission(trim(req.getParameter("transmission")));
        c.setColor(trim(req.getParameter("color")));
        c.setLocation(trim(req.getParameter("location")));

        try { c.setManufacturingYear(Integer.parseInt(trim(req.getParameter("manufacturingYear")))); }
        catch (NumberFormatException e) { c.setManufacturingYear(0); }

        try { c.setSeatingCapacity(Integer.parseInt(trim(req.getParameter("seatingCapacity")))); }
        catch (NumberFormatException e) { c.setSeatingCapacity(0); }

        try { c.setPricePerDay(Double.parseDouble(trim(req.getParameter("pricePerDay")))); }
        catch (NumberFormatException e) { c.setPricePerDay(0); }

        return c;
    }

    /** Returns a validation error message, or null if valid. */
    private String validate(BusinessCarBean c) {
        if (blank(c.getRegistrationNumber())) return "Registration number is required.";
        if (blank(c.getCarName()))            return "Car name is required.";
        if (blank(c.getBrand()))              return "Brand is required.";
        if (blank(c.getModel()))              return "Model is required.";
        if (c.getManufacturingYear() < 1900 || c.getManufacturingYear() > 2100)
            return "Please enter a valid manufacturing year (1900–2100).";
        if (c.getPricePerDay() <= 0)          return "Price per day must be greater than zero.";
        if (c.getSeatingCapacity() < 1)       return "Seating capacity must be at least 1.";
        return null;
    }

    private void forwardToList(HttpServletRequest req, HttpServletResponse res,
                               BusinessDAO dao, String businessId)
            throws Exception, ServletException, IOException {
        req.setAttribute("cars", dao.getCarsByBusiness(businessId));
        req.setAttribute("mode", "list");
        req.getRequestDispatcher("manage-cars.jsp").forward(req, res);
    }

    /** Reads BUSINESS_ID from session and validates the USER_ROLE. Returns null and redirects on failure. */
    private String getAuthenticatedBusinessId(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null) { res.sendRedirect("business-login.jsp"); return null; }
        String businessId = (String) session.getAttribute("BUSINESS_ID");
        String role       = (String) session.getAttribute("USER_ROLE");
        if (businessId == null || !"BUSINESS_PARTNER".equals(role)) {
            res.sendRedirect("business-login.jsp");
            return null;
        }
        return businessId;
    }

    private String trim(String s)    { return s == null ? "" : s.trim(); }
    private boolean blank(String s)  { return s == null || s.trim().isEmpty(); }
}
