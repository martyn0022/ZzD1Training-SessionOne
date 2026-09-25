/// Child table of ClaimBenefit: one row per coverage item, normalized from
/// the data dictionary's semi-structured coverage_items column. Loose
/// FK-by-string (BenefitKey), matching the codebase convention -- no
/// %Relationship. Seeded by ClaimLoader as insurer reference data.
Class D1.Mock.Data.CoverageItem Extends %Persistent
{

/// Links to ClaimBenefit.BenefitKey
Property BenefitKey As %String(MAXLEN = 100) [ Required ];

Index BenefitKeyIdx On BenefitKey;

/// e.g. "1.1"
Property CoverageItemNo As %String(MAXLEN = 20);

/// e.g. "ROOM"
Property CoverageCode As %String(MAXLEN = 50);

/// e.g. "Room & Board"
Property CoverageName As %String(MAXLEN = 100);

/// e.g. "PerDay"
Property CoverageType As %String(MAXLEN = 50);

Property LimitAmount As %Numeric(SCALE = 2);

/// e.g. "THB"
Property LimitUnit As %String(MAXLEN = 20);

Property Remark As %String(MAXLEN = 255);

Storage Default
{
<Data name="CoverageItemDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>BenefitKey</Value>
</Value>
<Value name="3">
<Value>CoverageItemNo</Value>
</Value>
<Value name="4">
<Value>CoverageCode</Value>
</Value>
<Value name="5">
<Value>CoverageName</Value>
</Value>
<Value name="6">
<Value>CoverageType</Value>
</Value>
<Value name="7">
<Value>LimitAmount</Value>
</Value>
<Value name="8">
<Value>LimitUnit</Value>
</Value>
<Value name="9">
<Value>Remark</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.CoverageItemD</DataLocation>
<DefaultData>CoverageItemDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.CoverageItemD</IdLocation>
<IndexLocation>^D1.Mock.Data.CoverageItemI</IndexLocation>
<StreamLocation>^D1.Mock.Data.CoverageItemS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
