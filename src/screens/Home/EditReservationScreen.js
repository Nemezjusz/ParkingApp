import React from 'react';
import { View, Text, SafeAreaView } from 'react-native';
import { styles } from '../../styles/styles';

// EditReservationScreen allows the user to edit a reservation
function EditReservationScreen({ route }) {
  // Get the reservation data passed from the previous screen
  const { reservation } = route.params;

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.appTitle}>Edit Reservation</Text>
      <Text style={styles.detailText}>Editing reservation for spot: {reservation.spot}</Text>
      {/* Implement edit functionality here */}
    </SafeAreaView>
  );
}

export default EditReservationScreen;