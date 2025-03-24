package com.etn.eshop;

public class Resource
{
	private String name;
	private String email;
	private String phone;
	private String type;
	private boolean available = true;//by default all resources are available
	private String idService;

	public Resource()
	{
	}

	public String getName()
	{
		return this.name;
	}
		
	public void setName(String name)
	{
		this.name = name;
	}

	public String getEmail()
	{
		return this.email;
	}
		
	public void setEmail(String email)
	{
		this.email = email;
	}

	public String getPhone()
	{
		return this.phone;
	}
		
	public void setPhone(String phone)
	{
		this.phone = phone;
	}

	public String getType()
	{
		return this.type;
	}
		
	public void setType(String type)
	{
		this.type = type;
	}

	public boolean isAvailable()
	{
		return this.available;
	}

	public void setAvailable(boolean available)
	{
		this.available = available;
	}

	public String getIdService()
	{
		return this.idService;
	}
		
	public void setIdService(String idService)
	{
		this.idService = idService;
	}

}
