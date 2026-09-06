package com.servlet;

/**
 * Bean / DTO for the CAR_DETAILS table.
 * Represents a car catalogue entry — used by CarSearchServlet,
 * CarDetailsServlet, and BookingDisplayServlet.
 */
public class CarModel {

    private int    carId;
    private String modelName;
    private String brand;
    private String bodyType;
    private String priceRange;

    private String fuelTypes;
    private String mileage;

    private String engine;
    private String power;
    private String torque;
    private String seatingCapacity;
    private String driveType;

    private String safetyRating;

    private String length;
    private String width;
    private String height;
    private String bootSpace;
    private String wheelbase;

    private String features;
    private String images;

    private String sourceUrl;

    // -----------------------------------------------------------------------
    // Getters and Setters
    // -----------------------------------------------------------------------

    public int getCarId()                        { return carId; }
    public void setCarId(int carId)              { this.carId = carId; }

    public String getModelName()                 { return modelName; }
    public void setModelName(String modelName)   { this.modelName = modelName; }

    public String getBrand()                     { return brand; }
    public void setBrand(String brand)           { this.brand = brand; }

    public String getBodyType()                  { return bodyType; }
    public void setBodyType(String bodyType)     { this.bodyType = bodyType; }

    public String getPriceRange()                { return priceRange; }
    public void setPriceRange(String priceRange) { this.priceRange = priceRange; }

    public String getFuelTypes()                 { return fuelTypes; }
    public void setFuelTypes(String fuelTypes)   { this.fuelTypes = fuelTypes; }

    public String getMileage()                   { return mileage; }
    public void setMileage(String mileage)       { this.mileage = mileage; }

    public String getEngine()                    { return engine; }
    public void setEngine(String engine)         { this.engine = engine; }

    public String getPower()                     { return power; }
    public void setPower(String power)           { this.power = power; }

    public String getTorque()                    { return torque; }
    public void setTorque(String torque)         { this.torque = torque; }

    public String getSeatingCapacity()                       { return seatingCapacity; }
    public void setSeatingCapacity(String seatingCapacity)   { this.seatingCapacity = seatingCapacity; }

    public String getDriveType()                 { return driveType; }
    public void setDriveType(String driveType)   { this.driveType = driveType; }

    public String getSafetyRating()                      { return safetyRating; }
    public void setSafetyRating(String safetyRating)     { this.safetyRating = safetyRating; }

    public String getLength()                    { return length; }
    public void setLength(String length)         { this.length = length; }

    public String getWidth()                     { return width; }
    public void setWidth(String width)           { this.width = width; }

    public String getHeight()                    { return height; }
    public void setHeight(String height)         { this.height = height; }

    public String getBootSpace()                 { return bootSpace; }
    public void setBootSpace(String bootSpace)   { this.bootSpace = bootSpace; }

    public String getWheelbase()                 { return wheelbase; }
    public void setWheelbase(String wheelbase)   { this.wheelbase = wheelbase; }

    public String getFeatures()                  { return features; }
    public void setFeatures(String features)     { this.features = features; }

    public String getImages()                    { return images; }
    public void setImages(String images)         { this.images = images; }

    public String getSourceUrl()                 { return sourceUrl; }
    public void setSourceUrl(String sourceUrl)   { this.sourceUrl = sourceUrl; }
}
