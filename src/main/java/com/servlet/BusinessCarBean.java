package com.servlet;

/**
 * Bean / DTO for the CAR_DETAILS table, scoped to a Business Partner.
 * Field names are kept stable so servlets and JSPs compile unchanged.
 * "businessId" maps to CAR_DETAILS.COMPANY_ID in the database.
 * No DB logic here — see BusinessDAO.
 */
public class BusinessCarBean {

    // Primary key  (format: bpc_YYYY_<millis>)
    private String carId;

    // Owner
    private String businessId;

    // Car identification
    private String registrationNumber;
    private String carName;
    private String brand;
    private String model;
    private int    manufacturingYear;

    // Specs
    private String bodyType;
    private String fuelType;
    private String transmission;
    private int    seatingCapacity;
    private String color;

    // Pricing & location
    private double pricePerDay;
    private String location;

    // Status: AVAILABLE | BOOKED | MAINTENANCE | INACTIVE
    private String availabilityStatus;

    // Timestamps (stored as String for simple JSP display)
    private String createdAt;
    private String updatedAt;

    // -----------------------------------------------------------------------
    // Constructors
    // -----------------------------------------------------------------------

    public BusinessCarBean() {}

    // -----------------------------------------------------------------------
    // Getters and Setters
    // -----------------------------------------------------------------------

    public String getCarId()                      { return carId; }
    public void   setCarId(String v)              { this.carId = v; }

    public String getBusinessId()                 { return businessId; }
    public void   setBusinessId(String v)         { this.businessId = v; }

    public String getRegistrationNumber()         { return registrationNumber; }
    public void   setRegistrationNumber(String v) { this.registrationNumber = v; }

    public String getCarName()                    { return carName; }
    public void   setCarName(String v)            { this.carName = v; }

    public String getBrand()                      { return brand; }
    public void   setBrand(String v)              { this.brand = v; }

    public String getModel()                      { return model; }
    public void   setModel(String v)              { this.model = v; }

    public int    getManufacturingYear()          { return manufacturingYear; }
    public void   setManufacturingYear(int v)     { this.manufacturingYear = v; }

    public String getBodyType()                   { return bodyType; }
    public void   setBodyType(String v)           { this.bodyType = v; }

    public String getFuelType()                   { return fuelType; }
    public void   setFuelType(String v)           { this.fuelType = v; }

    public String getTransmission()               { return transmission; }
    public void   setTransmission(String v)       { this.transmission = v; }

    public int    getSeatingCapacity()            { return seatingCapacity; }
    public void   setSeatingCapacity(int v)       { this.seatingCapacity = v; }

    public String getColor()                      { return color; }
    public void   setColor(String v)              { this.color = v; }

    public double getPricePerDay()                { return pricePerDay; }
    public void   setPricePerDay(double v)        { this.pricePerDay = v; }

    public String getLocation()                   { return location; }
    public void   setLocation(String v)           { this.location = v; }

    public String getAvailabilityStatus()         { return availabilityStatus; }
    public void   setAvailabilityStatus(String v) { this.availabilityStatus = v; }

    public String getCreatedAt()                  { return createdAt; }
    public void   setCreatedAt(String v)          { this.createdAt = v; }

    public String getUpdatedAt()                  { return updatedAt; }
    public void   setUpdatedAt(String v)          { this.updatedAt = v; }
}
