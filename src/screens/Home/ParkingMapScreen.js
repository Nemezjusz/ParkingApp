import React, { useState } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  SafeAreaView,
  Modal,
  Pressable,
} from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';

// Import styles and theme
import { styles } from '../../styles/styles';
import { theme } from '../../theme/theme';

// Import data
import { parkingSpots } from '../../data/parkingSpotsData';
import { userReservations } from '../../data/userReservationsData';

// ParkingMapScreen displays the parking map and user's reservations
function ParkingMapScreen({ navigation }) {
  // State for modal visibility and selected reservation
  const [modalVisible, setModalVisible] = useState(false);
  const [selectedReservation, setSelectedReservation] = useState(null);

  // Handle parking spot press
  const handleParkingSpotPress = (spot) => {
    // Navigate to ParkingSpotDetailsScreen, passing the spot data
    navigation.navigate('ParkingSpotDetails', { spot });
  };

  // Handle reservation item press
  const handleReservationPress = (reservation) => {
    // Navigate to ReservationDetailsScreen, passing the reservation data
    navigation.navigate('ReservationDetails', { reservation });
  };

  // Open modal for edit/delete options
  const openModal = (reservation) => {
    setSelectedReservation(reservation);
    setModalVisible(true);
  };

  return (
    <SafeAreaView style={styles.container}>
      {/* Parking Map Title */}
      <Text style={styles.sectionTitle}>Company Parking Map</Text>

      {/* Parking Map Container */}
      <View style={styles.mapContainer}>
        {/* Render parking spots */}
        {parkingSpots.map((row, rowIndex) => (
          <View key={rowIndex} style={styles.parkingSpotRow}>
            {row.map((spot) => (
              <TouchableOpacity
                key={spot.id}
                style={[
                  styles.parkingSpot,
                  {
                    backgroundColor:
                      spot.status === 'available'
                        ? theme.availableColor
                        : spot.status === 'reserved'
                        ? theme.reservedColor
                        : theme.occupiedColor,
                  },
                ]}
                onPress={() => handleParkingSpotPress(spot)}
              >
                <Text style={styles.parkingSpotLabel}>{spot.id}</Text>
              </TouchableOpacity>
            ))}
          </View>
        ))}
      </View>

      {/* User's Reservations Title */}
      <Text style={styles.sectionTitle}>Your Parking Reservations</Text>

      {/* Reservation List */}
      <FlatList
        data={userReservations}
        renderItem={({ item }) => (
          <TouchableOpacity onPress={() => handleReservationPress(item)}>
            <View
              style={[
                styles.reservationItem,
                {
                  backgroundColor:
                    item.status === 'reserved'
                      ? theme.reservedColor
                      : theme.occupiedColor,
                },
              ]}
            >
              <View>
                <Text style={styles.reservationSpot}>Spot: {item.spot}</Text>
                <Text style={styles.reservationStatus}>
                  Status: {item.status.charAt(0).toUpperCase() + item.status.slice(1)}
                </Text>
                <Text style={styles.reservationTime}>Time: {item.time}</Text>
              </View>
              <TouchableOpacity onPress={() => openModal(item)}>
                <Ionicons name="ellipsis-vertical" size={24} color={theme.textColor} />
              </TouchableOpacity>
            </View>
          </TouchableOpacity>
        )}
        keyExtractor={(item) => item.key}
        contentContainerStyle={styles.reservationList}
      />

      {/* Modal for Edit/Delete Options */}
      <Modal
        animationType="fade"
        transparent={true}
        visible={modalVisible}
        onRequestClose={() => {
          setModalVisible(false);
          setSelectedReservation(null);
        }}
      >
        <Pressable
          style={styles.modalOverlay}
          onPress={() => setModalVisible(false)}
        >
          <View style={styles.modalView}>
            {/* Edit Button */}
            <Pressable
              style={styles.modalButton}
              onPress={() => {
                setModalVisible(false);
                navigation.navigate('EditReservation', {
                  reservation: selectedReservation,
                });
              }}
            >
              <Text style={styles.modalButtonText}>Edit</Text>
            </Pressable>
            {/* Delete Button */}
            <Pressable
              style={styles.modalButton}
              onPress={() => {
                setModalVisible(false);
                // Implement delete functionality here
                // e.g., remove the reservation from the list
              }}
            >
              <Text style={styles.modalButtonText}>Delete</Text>
            </Pressable>
          </View>
        </Pressable>
      </Modal>
    </SafeAreaView>
  );
}

export default ParkingMapScreen;