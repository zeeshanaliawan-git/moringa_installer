package com.etn.asimina.beans;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;
import com.etn.asimina.util.PortalHelper;

public class ProductVariant
{
	private String variantId;
	private String variantUUID;
	private String variantName;
	private String unformattedVariantPrice;
	private long variantStock;

	private String productId;
	private String productUUID;
	private String productName;
	private String productType;
	private String productUrl;
	private String brandName;
	private String catalogId;
	private String catalogName;
	private String catalogType;
	private String sku;
	private String ean;
	private String tagId;

	private String folderId;
	private String folderName;
	
    private String currencyFreq = "";
    private boolean priceTaxIncluded;
    private boolean showAmountWithTax;
    private TaxPercentage taxPercentage;
    private TaxPercentage taxPercentageWT;

    private double productPrice;
    private double productOldPrice;
    private double productPriceWT;
    private double productOldPriceWT;

    private String formattedPrice = "";
    private String formattedOldPrice = "";
    private String priceValue = "";
    private String unitPrice = "";
    private String priceOldValue = "";

    private JSONArray additionalFee;
    private JSONArray additionalFeeWT;
    private JSONArray comewith;
    private JSONObject promotion;
	
	private int duration;
	private int discountDuration;
	
	private String imageUrl;
	private String imagePath;
	private String imageAlt;

	private String thumbnailUrl;
	private String thumbnailPath;
	private String imageName;
	
	private String frequency = "";
	private String productVersion = "V1";
	
	private JSONArray attributes;
	
	private JSONArray productCategories;
	
	public JSONObject toJSON(){
		JSONObject json = new JSONObject();
		try{
			json.put("variantId",variantId);
			json.put("variantUUID",variantUUID);
			json.put("variantName",variantName);
			json.put("unformattedVariantPrice",unformattedVariantPrice);
			json.put("variantStock",variantStock);
			json.put("productId",productId);
			json.put("productUUID",productUUID);
			json.put("productName",productName);
			json.put("productType",productType);
			json.put("productUrl",productUrl);
			json.put("brandName",brandName);
			json.put("catalogId",catalogId);
			json.put("folderId",folderId);
			json.put("folderName",folderName);
			json.put("catalogName",catalogName);
			json.put("catalogType",catalogType);
			json.put("sku",sku);
			json.put("ean",ean);
			json.put("tagId",tagId);
			json.put("currencyFreq",currencyFreq);
			json.put("priceTaxIncluded",priceTaxIncluded);
			json.put("showAmountWithTax",showAmountWithTax);
			json.put("taxPercentage",taxPercentage.toJSON());
			json.put("taxPercentageWT",taxPercentageWT);
			json.put("productPrice",productPrice);
			json.put("productOldPrice",productOldPrice);
			json.put("productPriceWT",productPriceWT);
			json.put("productOldPriceWT",productOldPriceWT);
			json.put("formattedPrice",formattedPrice);
			json.put("formattedOldPrice",formattedOldPrice);
			json.put("priceValue",priceValue);
			json.put("unitPrice",unitPrice);
			json.put("priceOldValue",priceOldValue);
			json.put("additionalFee",additionalFee);
			json.put("additionalFeeWT",additionalFeeWT);
			json.put("comewith",comewith);
			json.put("promotion",promotion);
			json.put("duration",duration);
			json.put("discountDuration",discountDuration);
			json.put("imageUrl",imageUrl);
			json.put("imagePath",imagePath);
			json.put("imageAlt",imageAlt);
			json.put("thumbnailUrl",thumbnailUrl);
			json.put("thumbnailPath",thumbnailPath);
			json.put("attributes",attributes);
			json.put("imageName",imageName);
		}catch(JSONException ex){
			ex.printStackTrace();
		}
		return json;
	}

    public JSONArray getAdditionalFee() {
        return additionalFee;
    }

    public void setAdditionalFee(JSONArray additionalFee) {
        this.additionalFee = additionalFee;
    }

    public JSONArray getAdditionalFeeWT() {
        return additionalFeeWT;
    }

    public void setAdditionalFeeWT(JSONArray additionalFeeWT) {
        this.additionalFeeWT = additionalFeeWT;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getCatalogId() {
        return catalogId;
    }

    public void setCatalogId(String catalogId) {
        this.catalogId = catalogId;
    }

    public String getCatalogName() {
        return catalogName;
    }

    public void setCatalogName(String catalogName) {
        this.catalogName = catalogName;
    }

    public JSONArray getComewith() {
        return comewith;
    }

    public void setComewith(JSONArray comewith) {
        this.comewith = comewith;
    }

    public String getCurrencyFreq() {
        return currencyFreq;
    }

    public void setCurrencyFreq(String currencyFreq) {
        this.currencyFreq = currencyFreq;
    }

    public int getDiscountDuration() {
        return discountDuration;
    }

    public void setDiscountDuration(int discountDuration) {
        this.discountDuration = discountDuration;
    }

    public String getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(String unitPrice) {
        this.unitPrice = unitPrice;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public String getFormattedOldPrice() {
        return formattedOldPrice;
    }

    public void setFormattedOldPrice(String formattedOldPrice) {
        this.formattedOldPrice = formattedOldPrice;
    }

    public String getFormattedPrice() {
        return formattedPrice;
    }

    public void setFormattedPrice(String formattedPrice) {
        this.formattedPrice = formattedPrice;
    }

    public String getImageAlt() {
        return imageAlt;
    }

    public void setImageAlt(String imageAlt) {
        this.imageAlt = imageAlt;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getPriceOldValue() {
        return priceOldValue;
    }

    public void setPriceOldValue(String priceOldValue) {
        this.priceOldValue = priceOldValue;
    }

    public boolean isPriceTaxIncluded() {
        return priceTaxIncluded;
    }

    public void setPriceTaxIncluded(boolean priceTaxIncluded) {
        this.priceTaxIncluded = priceTaxIncluded;
    }

    public String getPriceValue() {
        return priceValue;
    }

    public void setPriceValue(String priceValue) {
        this.priceValue = priceValue;
    }

    public String getProductId() {
        return productId;
    }

    public void setProductId(String productId) {
        this.productId = productId;
    }
	
	public String getProductUUID() {
        return productUUID;
    }

    public void setProductUUID(String productUUID) {
        this.productUUID = productUUID;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public double getProductOldPrice() {
        return productOldPrice;
    }

    public void setProductOldPrice(double productOldPrice) {
        this.productOldPrice = productOldPrice;
    }

    public double getProductOldPriceWT() {
        return productOldPriceWT;
    }

    public void setProductOldPriceWT(double productOldPriceWT) {
        this.productOldPriceWT = productOldPriceWT;
    }

    public double getProductPrice() {
        return productPrice;
    }

    public void setProductPrice(double productPrice) {
        this.productPrice = productPrice;
    }

    public double getProductPriceWT() {
        return productPriceWT;
    }

    public void setProductPriceWT(double productPriceWT) {
        this.productPriceWT = productPriceWT;
    }

    public String getProductType() {
        return productType;
    }

    public void setProductType(String productType) {
        this.productType = productType;
    }

    public JSONObject getPromotion() {
        return promotion;
    }

    public void setPromotion(JSONObject promotion) {
        this.promotion = promotion;
    }

    public boolean isShowAmountWithTax() {
        return showAmountWithTax;
    }

    public void setShowAmountWithTax(boolean showAmountWithTax) {
        this.showAmountWithTax = showAmountWithTax;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public TaxPercentage getTaxPercentage() {
        return taxPercentage;
    }

    public void setTaxPercentage(TaxPercentage taxPercentage) {
        this.taxPercentage = taxPercentage;
    }

    public TaxPercentage getTaxPercentageWT() {
        return taxPercentageWT;
    }

    public void setTaxPercentageWT(TaxPercentage taxPercentageWT) {
        this.taxPercentageWT = taxPercentageWT;
    }

    public String getVariantId() {
        return variantId;
    }

    public void setVariantId(String variantId) {
        this.variantId = variantId;
    }
	
	public String getVariantUUID() {
        return variantUUID;
    }

    public void setVariantUUID(String variantUUID) {
        this.variantUUID = variantUUID;
    }

    public String getVariantName() {
        return variantName;
    }

    public void setVariantName(String variantName) {
        this.variantName = variantName;
    }

    public long getVariantStock() {
        return variantStock;
    }

    public void setVariantStock(long variantStock) {
        this.variantStock = variantStock;
    }

    public JSONArray getAttributes() {
        return attributes;
    }

    public void setAttributes(JSONArray attributes) {
        this.attributes = attributes;
    }
		
    public String getProductUrl() {
        return productUrl;
    }

    public void setProductUrl(String productUrl) {
        this.productUrl = productUrl;
    }
	
    public String getTagId() {
        return tagId;
    }

    public void setTagId(String tagId) {
        this.tagId = tagId;
    }

    public String getCatalogType() {
        return catalogType;
    }

    public void setCatalogType(String catalogType) {
        this.catalogType = catalogType;
    }

    public String getUnformattedVariantPrice() {
        return unformattedVariantPrice;
    }

    public void setUnformattedVariantPrice(String unformattedVariantPrice) {
        this.unformattedVariantPrice = unformattedVariantPrice;
    }

    public String getThumbnailPath() {
        return thumbnailPath;
    }

    public void setThumbnailPath(String thumbnailPath) {
        this.thumbnailPath = thumbnailPath;
    }

    public String getThumbnailUrl() {
        return thumbnailUrl;
    }

    public void setThumbnailUrl(String thumbnailUrl) {
        this.thumbnailUrl = thumbnailUrl;
    }
	
    public String getImageName() {
        return imageName;
    }

    public void setImageName(String imageName) {
        this.imageName = imageName;
    }

    public String getFolderId() {
        return folderId;
    }

    public void setFolderId(String folderId) {
        this.folderId = folderId;
    }

    public String getFolderName() {
        return folderName;
    }

    public void setFolderName(String folderName) {
        this.folderName = folderName;
    }
	
    public String getFrequency() {
        return frequency;
    }

    public void setFrequency(String frequency) {
        this.frequency = frequency;
    }

    public String getEan() {
        return ean;
    }

    public void setEan(String ean) {
        this.ean = ean;
    }
	
	public String getProductVersion()
	{
		return productVersion;
	}
	
	public void setProductVersion(String productVersion)
	{
		this.productVersion = productVersion;
	}
	
	public boolean hasFrequency()
	{
		//for v1 products we always assume price given for product has a frequency attached to it so we must return true for old products
		if("offer_postpaid".equals(productType))
		{
			return true;
		}
		//frequency is only applicable for these type of products but in database all products have a default value set so we must use it accordingly
		if(PortalHelper.isFrequencyApplicable(productType, productVersion) && PortalHelper.parseNull(frequency).length() > 0)
		{
			return true;
		}
		
		return false;
	}

	public void setProductCategories(JSONArray productCategories)
	{
		this.productCategories = productCategories;
	}

	public JSONArray getProductCategories()
	{
		return productCategories;
	}
}