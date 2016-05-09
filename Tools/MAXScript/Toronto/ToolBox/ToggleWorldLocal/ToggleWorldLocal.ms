--macroScript ToggleViewLocaltoWorld category:"GameloftTools" toolTip:"World/Local Toggle"
(
if( getRefCoordSys() == #world  ) then setRefCoordSys(#local)
else setRefCoordSys(#world );
)