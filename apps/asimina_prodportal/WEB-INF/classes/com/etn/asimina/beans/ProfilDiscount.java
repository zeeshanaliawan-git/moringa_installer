package com.etn.asimina.beans;

public class ProfilDiscount
{
	private double overallDiscount = 0;
	private String overallDiscountType = "";
	private double productDiscount = 0;
	private String productDiscountType = "";
	private double catalogDiscount = 0;
	private String catalogDiscountType = "";
	
    public double getCatalogDiscount() {
        return catalogDiscount;
    }

    public void setCatalogDiscount(double catalogDiscount) {
        this.catalogDiscount = catalogDiscount;
    }

    public String getCatalogDiscountType() {
        return catalogDiscountType;
    }

    public void setCatalogDiscountType(String catalogDiscountType) {
        this.catalogDiscountType = catalogDiscountType;
    }

    public double getOverallDiscount() {
        return overallDiscount;
    }

    public void setOverallDiscount(double overallDiscount) {
        this.overallDiscount = overallDiscount;
    }

    public String getOverallDiscountType() {
        return overallDiscountType;
    }

    public void setOverallDiscountType(String overallDiscountType) {
        this.overallDiscountType = overallDiscountType;
    }

    public double getProductDiscount() {
        return productDiscount;
    }

    public void setProductDiscount(double productDiscount) {
        this.productDiscount = productDiscount;
    }

    public String getProductDiscountType() {
        return productDiscountType;
    }

    public void setProductDiscountType(String productDiscountType) {
        this.productDiscountType = productDiscountType;
    }
}