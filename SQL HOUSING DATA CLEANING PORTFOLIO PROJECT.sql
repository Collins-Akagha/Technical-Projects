/*

CLEANING DATA IN SQL QUERIES

*/

SELECT *
FROM [Portfolio Projects]..NashvilleHousing
ORDER BY [UniqueID ]
--------------------------------------------------------------------------------------------------------

--STANDARDIZE DATE FORMAT

SELECT SaleDate, CONVERT(Date, SaleDate) ConvertedSaleDate
FROM [Portfolio Projects]..NashvilleHousing


ALTER TABLE [Portfolio Projects]..NashvilleHousing
ADD ConvertedSaleDate Date;

UPDATE [Portfolio Projects]..NashvilleHousing
SET ConvertedSaleDate = CONVERT(Date, SaleDate) 






---------------------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM [Portfolio Projects]..NashvilleHousing A
JOIN [Portfolio Projects]..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [Portfolio Projects]..NashvilleHousing A
JOIN [Portfolio Projects]..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [Portfolio Projects]..NashvilleHousing A
JOIN [Portfolio Projects]..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null










---------------------------------------------------------------------------------------------------------

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM [Portfolio Projects]..NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM [Portfolio Projects]..NashvilleHousing

ALTER TABLE [Portfolio Projects]..NashvilleHousing
ADD ExactPropertyAddress varchar(100);

UPDATE [Portfolio Projects]..NashvilleHousing
SET ExactPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Portfolio Projects]..NashvilleHousing
ADD PropertyAddressCity varchar(100);

UPDATE [Portfolio Projects]..NashvilleHousing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


/*
FOR OWNERADDRESS
*/

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Portfolio Projects]..NashvilleHousing

ALTER TABLE [Portfolio Projects]..NashvilleHousing
ADD OwnerExactAddress nvarchar(255);

UPDATE [Portfolio Projects]..NashvilleHousing
SET OwnerExactAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Portfolio Projects]..NashvilleHousing
ADD OwnerCityAddress nvarchar(100);

UPDATE [Portfolio Projects]..NashvilleHousing
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Portfolio Projects]..NashvilleHousing
ADD OwnerStateAddress varchar (50);

UPDATE [Portfolio Projects]..NashvilleHousing
SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



---------------------------------------------------------------------------------------------------------

--STANDARDIZING SALEPRICE COLUMN

SELECT SalePrice, (CAST(SalePrice as Money))
FROM [Portfolio Projects]..NashvilleHousing

ALTER TABLE [Portfolio Projects]..NashvilleHousing
ADD PriceOfSale money;

UPDATE [Portfolio Projects]..NashvilleHousing
SET PriceOfSale = (CAST(SalePrice as Money))



---------------------------------------------------------------------------------------------------------

--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" COLUMN


SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM [Portfolio Projects]..NashvilleHousing
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END SoldAsVacantConverted
FROM [Portfolio Projects]..NashvilleHousing

UPDATE [Portfolio Projects]..NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END 






----------------------------------------------------------------------------------------------------------

--REMOVE DUPLICATES

WITH Duplicate AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress,
				SalePrice, SaleDate, 
				LegalReference
	ORDER BY UniqueID) DUplicateRows
FROM [Portfolio Projects]..NashvilleHousing
)

DELETE
FROM Duplicate
WHERE DUplicateRows > 1









-----------------------------------------------------------------------------------------------------------

--DELETE UNUSED/UNNECESSARY COLUMNS

ALTER TABLE [Portfolio Projects]..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

ALTER TABLE [Portfolio Projects]..NashvilleHousing
DROP COLUMN SalePrice



																			--BY AKAGHA COLLINS
-----------------------------------------------------------------------------------------------------------