# beetle
Beetle is a shuttle registrations application for Binusian. The shuttle route is between Anggrek and Alsut Binus campuses.


## Role-based Views
The application views are divided into 3 roles:
- Users
- Drivers
- Admin

Except for the profile page, each roles have access to different views.

### Users
The users side of the app is for the users who want to register for the shuttle schedules. The users can select to either view today's schedule or register for a shuttle slot. User can register from either one of the pick-up point at Binus alsut or Binus anggrek. The users also have the my reservation page to view the schedules they have registered for. The user can also view the information of the shuttle schedule such as the shuttle current location, driver's name, and route.

### Drivers
The driver can view the schedules assigned to them by the admin. The driver can change the status of each trip such as start trip to change the status of the shuttle from standby -> on the way. When the driver change the status to on the way, they will be directed to the live tracking view which will ask the driver for location access permission and there will be a "complete" button to change the status of the shuttle from "on the way" -> "completed".

### Admin
The admin side of the app is held by the admin who will assign the driver and shuttle type (bus1/bus2/bus elf) to each slot. The slots that the admin can set is the slots for tomorrow schedule. The reason why it is limited to d-1 schedule is due to the user able to cancel their reservation. If the reservation is cancelled and the available seats is the same as the default total seats, then the slots won't be shown and admin don't need to assign any driver or shuttle type to the slot. The admin can also set the active window of the registration which is the date window from the starting date and the last date the user can register shuttle for.

## Tools used
- Flutter with dart
- Firebase firestore as database
- Firebase authentication for login and sign up authentication