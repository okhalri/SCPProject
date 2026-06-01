--!strict
const DataSystem = script.Parent
const Types = require(DataSystem.Types)

const DataServer = {
	HeadVectors = require(DataSystem.DataFields.HeadVectors)
}

for i, DataField in DataServer :: {[string]: Types.DataField<any>} do
	DataField.load()
end



return DataServer