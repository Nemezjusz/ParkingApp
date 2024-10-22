import React from 'react';
import { View, Text, SafeAreaView } from 'react-native';
import { styles } from '../../styles/styles';

// ParkingSpotDetailsScreen displays details of a parking spot
function ParkingSpotDetailsScreen({ route }) {
  // Get the spot data passed from the previous screen
  const { spot } = route.params;

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.appTitle}>Parking Spot Details</Text>
      <Text style={styles.detailText}>Spot ID: {spot.id}</Text>
      <Text style={styles.detailText}>
        Status: {spot.status.charAt(0).toUpperCase() + spot.status.slice(1)}
      </Text>
      {/* Add more details as needed */}
    </SafeAreaView>
  );
}

export default ParkingSpotDetailsScreen;