/*
Cleaning Data in SQL Queries
*/

select *
From PortfolioProject..NashvileHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

 --------------------------------------------------------------------------------------------------------------------------

select SaleDate, Convert(Date,SaleDate)
From PortfolioProject..NashvileHousing

select SaleDateConverted, Convert(Date,SaleDate) 
From PortfolioProject..NashvileHousing

Update NashvileHousing -- Updates data table
Set SaleDate = Convert(Date,SaleDate)

Alter Table NashvileHousing -- Alters data table 
Add SaleDateConverted Date; -- Use if update statment dosn't work

Update NashvileHousing
Set SaleDateConverted = Convert(Date,SaleDate)

-- Populate Property Address data

--------------------------------------------------------------------------------------------------------------------------

Select * 
From PortfolioProject..NashvileHousing
Where PropertyAddress is null 
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress ,ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvileHousing a
Join PortfolioProject..NashvileHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  Where a.PropertyAddress is null 

Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvileHousing a
Join PortfolioProject..NashvileHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  Where a.PropertyAddress is null 

-- ISNULL checks for null values
-- Example: 
-- Step 1: checks for null values in one colume (a.PropertyAddress)
-- Step 2: Replaces null values with values from another chosen colume with the same data type (b.PropertyAddress)

-- Breaking out Address into Individual Columns (Address, City, State)

--------------------------------------------------------------------------------------------------------------------------

Select PropertyAddress
From PortfolioProject..NashvileHousing -- , separating different columes or values is known as a Delimiter
--Where PropertyAddress is null 
--Order by ParcelID

-- Using a substring
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address
From PortfolioProject..NashvileHousing

 -- The 1 in this code refers to the first value being looked at and continues until the , is found
 -- Adding a -1 removes the , from the end of the output

 -- Starting Substring from a different position (at comma)
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvileHousing

 -- Since every property address is a different lenght using the LEN (length) command helps 

 -- Updating and Altering data table with new substring of PropertySplitAddress and PropertySplitCity

 ALTER TABLE NashvileHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvileHousing
Add PropertySplitCity Nvarchar(255);

Update NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select * 
From PortfolioProject..NashvileHousing

-- Using PARSENAME 
-- PARSENAME looks for periods (.) in the code, if none are found then PARSENAME will not work
-- To change/replace commas (,) with periods (.) simple use the REPLACE command

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From PortfolioProject..NashvileHousing

-- PARSENAME gives outputs backwards to change this simply change the order or the chosen columns (from 1,2,3 to 3,2,1)

ALTER TABLE NashvileHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvileHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvileHousing
Add OwnerSplitState Nvarchar(255);

Update NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select * 
From PortfolioProject..NashvileHousing

-- Updating and Altering data table with new PARSENAME of OwnerSplitAddress and OwnerSplitCity


-- Change Y and N to Yes and No in "Sold as Vacant" field

-----------------------------------------------------------------------------------------------------------------------------------------------------------

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvileHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant
 , Case when SoldAsVacant = 'Y' Then 'Yes'
        When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From PortfolioProject..NashvileHousing

Update NashvileHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
        When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
-- Sometimes the data won't be recognised by the code. Restarting SQL or redownloading the dataset has worked for me in this instance

-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

From PortfolioProject..NashvileHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1 



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject..NashvileHousing

ALTER TABLE PortfolioProject..NashvileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvileHousing
DROP COLUMN SaleDate

-- This alters the raw data so use with care and make sure you have a ready backup of the original data as once this is run the codes above will not work properly as some columns have been deleted from the raw dataset