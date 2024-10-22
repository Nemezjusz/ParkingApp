import React from 'react';
import { View, Text, SafeAreaView } from 'react-native';
import { styles } from '../../styles/styles';

// ReservationDetailsScreen displays details of a reservation
function ReservationDetailsScreen({ route }) {
  // Get the reservation data passed from the previous screen
  const { reservation } = route.params;

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.appTitle}>Reservation Details</Text>
      <Text style={styles.detailText}>Spot: {reservation.spot}</Text>
      <Text style={styles.detailText}>
        Status: {reservation.status.charAt(0).toUpperCase() + reservation.status.slice(1)}
      </Text>
      <Text style={styles.detailText}>Time: {reservation.time}</Text>
      {/* Add more details as needed */}
    </SafeAreaView>
  );
}

export default ReservationDetailsScreen;