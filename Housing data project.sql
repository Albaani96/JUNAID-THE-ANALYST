SELECT *
FROM project1..Housing_Project

--standardize date format

SELECT DateConverted, cast(SaleDate as DATE)
FROM project1..Housing_Project

ALTER TABLE project1..Housing_Project
ADD DateConverted DATE;

UPDATE project1..Housing_Project
SET DateConverted = cast(SaleDate as DATE)

-- Populate public address data

SELECT *
FROM project1..Housing_Project
WHERE propertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM project1..Housing_Project a
 JOIN project1..Housing_Project b
 ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
 SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM project1..Housing_Project a
 JOIN project1..Housing_Project b
 ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking out Address into individual Columns(Address, City, State)

SELECT PropertyAddress
FROM project1..Housing_Project
--WHERE propertyAddress is null

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM project1..Housing_Project

ALTER TABLE project1..Housing_Project
ADD PropertySplitAddress NVARCHAR(255)

UPDATE project1..Housing_Project
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE project1..Housing_Project
ADD PropertySplitCity NVARCHAR(255)

UPDATE project1..Housing_Project
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM project1..Housing_Project

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
FROM project1..Housing_Project

ALTER TABLE project1..Housing_Project
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE project1..Housing_Project
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE project1..Housing_Project
ADD OwnerSplitCity NVARCHAR(255)

UPDATE project1..Housing_Project
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE project1..Housing_Project
ADD OwnerSplitState NVARCHAR(255)

UPDATE project1..Housing_Project
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Change Y and N to YES and NO in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant)
FROM project1..Housing_project

SELECT SoldAsVacant,
CASE
   WHEN SoldAsVacant = 'Y' THEN 'YES'
   WHEN SoldAsVacant = 'N' THEN 'NO'
   ELSE SoldAsVacant
END
FROM project1..Housing_project

UPDATE project1..Housing_project
SET SoldAsVacant = CASE
   WHEN SoldAsVacant = 'Y' THEN 'YES'
   WHEN SoldAsVacant = 'N' THEN 'NO'
   ELSE SoldAsVacant
END

-- REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER( ) OVER(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
ORDER BY
        UniqueID
		) row_num
FROM project1..Housing_Project
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1


-- DELETE UNWANTED COLUMNS

SELECT *
FROM project1..Housing_Project

ALTER TABLE project1..Housing_project
DROP COLUMN OwnerAddress, TaxDistrict
  



