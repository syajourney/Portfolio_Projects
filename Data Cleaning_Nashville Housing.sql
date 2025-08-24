
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE

SELECT SaleDate
FROM NashvilleHousing



-- Populate Property Address data

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) PropertyAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) PropertyCity
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertyCity = LTRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)))

UPDATE NashvilleHousing
SET PropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

SELECT PropertyAddress, PropertyCity
FROM NashvilleHousing




SELECT OwnerAddress
FROM NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 1) OwnerState,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) OwnerCity,
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerState = LTRIM(PARSENAME(REPLACE(OwnerAddress,',','.'), 1))

ALTER TABLE NashvilleHousing
ADD OwnerCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerCity = LTRIM(PARSENAME(REPLACE(OwnerAddress,',','.'), 2))

UPDATE NashvilleHousing
SET OwnerAddress = LTRIM(PARSENAME(REPLACE(OwnerAddress,',','.'), 3))

SELECT *
FROM NashvilleHousing



-- Standardized values in 'Sold as Vacant' column

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END



-- Remove Duplicates

SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY uniqueID) row_num
FROM NashvilleHousing
ORDER BY ParcelID


WITH RowNumber AS 
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY uniqueID) row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumber
WHERE row_num > 1
ORDER BY PropertyAddress


WITH RowNumber AS 
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY uniqueID) row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumber
WHERE row_num > 1



-- Delete Unused Columns


SELECT *
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, Acreage, TaxDistrict, TotalValue

