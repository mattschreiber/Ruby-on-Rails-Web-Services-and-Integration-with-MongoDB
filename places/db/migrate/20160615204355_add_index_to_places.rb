class AddIndexToPlaces < ActiveRecord::Migration
   # add a 2dsphere index to Zip.loc field
  def up
      Place.collection.indexes.create_one({'geometry.geolocation' => Mongo::Index::GEO2DSPHERE})
  end

  def down
      Zip.collection.indexes.drop_one("geometry.geolocation_2dsphere")
  end
end
