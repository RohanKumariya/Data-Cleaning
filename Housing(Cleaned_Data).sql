select * from[dbo].[NashvilleHousing]

--standardized date 
select SaleDateConverted, CONVERT(date,SaleDate) from[dbo].[NashvilleHousing]

Alter Table NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


--populating property address 

select * from [dbo].[NashvilleHousing]
--where propertyaddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [dbo].[NashvilleHousing] a
join [dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [dbo].[NashvilleHousing] a
join [dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out address into individual columns

select PropertyAddress from [dbo].[NashvilleHousing]

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as CIty 
from [dbo].[NashvilleHousing] 

Alter Table NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
ADD PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

-- Updating owner address
Select OwnerAddress from[dbo].[NashvilleHousing]

select PARSENAME(Replace(OwnerAddress,',','.'),3) as OwnerAddress,
PARSENAME(Replace(OwnerAddress,',','.'),2)as OwnerCity,
PARSENAME(Replace(OwnerAddress,',','.'),1)as OwnerState 
from [dbo].[NashvilleHousing]

Alter Table NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3) 

Alter Table NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)
--------------
Alter Table NashvilleHousing
ADD OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

--- Minor Changes

select distinct [SoldAsVacant], COUNT(SoldAsVacant) 
from[dbo].[NashvilleHousing]
group by [SoldAsVacant]
order  by 2

select [SoldAsVacant],
case when [SoldAsVacant] = 'Y' THEN 'Yes'
	when [SoldAsVacant] = 'N' THEN 'No'
	ELSE [SoldAsVacant]
	END
from[dbo].[NashvilleHousing]

Update[dbo].[NashvilleHousing]
set [SoldAsVacant] = case when [SoldAsVacant] = 'Y' THEN 'Yes'
	when [SoldAsVacant] = 'N' THEN 'No'
	ELSE [SoldAsVacant]
	END

--Removing Duplicate Data
with RowNumCTE as (
 select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
from[dbo].[NashvilleHousing]
--Order BY ParcelID
)

Delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress

-- Removing Unused Columns
Alter Table[dbo].[NashvilleHousing]
Drop Column [OwnerAddress],[TaxDistrict],[PropertyAddress]
Alter Table[dbo].[NashvilleHousing]
Drop Column [SaleDate]
