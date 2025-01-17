--Data cleaning in SQL Queries

--Standardize Date Format

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

SELECT SaleDate, SaleDateConverted
FROM NashvilleHousing


-- Populate Property Address Data

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, ISNULL(a.PropertyAddress, b.PropertyAddress) AS PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;


--Breaking Address Into Individual Columns(Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR (260);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR (260);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing


SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR (260);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR (260);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR (260);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


SELECT*
FROM NashvilleHousing


--CHANGE Y AND N TO YES AND NO "SOLD AS VACANT" FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


--REMOVE DUPLICATES


WITH NumberedRows AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM NashvilleHousing
)
SELECT*
FROM NumberedRows
WHERE row_num > 1
ORDER BY ParcelID;


--DELETE UNUSED COLUMNS


SELECT*
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate