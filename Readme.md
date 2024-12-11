
# Indoor Localisation: A Wi-Fi, Cellular, and MEMS Sensor Fusion Approach

In today’s fast-paced world, indoor navigation is becoming increasingly vital. From navigating complex hospital layouts to finding your way in sprawling malls or office buildings, the need for accurate indoor positioning systems (IPS) is more pressing than ever. My research focuses on developing a low-cost, accurate IPS that leverages existing infrastructure and ubiquitous technologies—Wi-Fi, cellular networks, and Micro Electro-Mechanical Systems (MEMS) sensors—to achieve superior results.

## The Problem
While Global Navigation Satellite Systems (GNSS) like GPS excel outdoors, their signals degrade within buildings due to structural attenuation. This limitation necessitates alternative solutions for determining location in indoor spaces. Many existing indoor positioning methods depend on expensive infrastructure or require extensive maintenance, limiting their scalability and affordability. My thesis explores an innovative, infrastructure-light solution that maximizes accuracy using sensor fusion.

## Research Highlights
### A Multi-Sensor Fusion Approach
The cornerstone of this research is the integration of three key technologies:

1. **Wi-Fi and Cellular Signal Fingerprinting**  
   Fingerprinting involves collecting signal strength data from Wi-Fi access points and cellular towers at predefined reference points. These datasets, collected offline, serve as the basis for real-time location prediction through K-Nearest Neighbour (KNN) algorithms.

2. **MEMS Sensors for Pedestrian Dead Reckoning (PDR)**  
   MEMS sensors embedded in smartphones (e.g., accelerometers, gyroscopes, and magnetometers) are employed for PDR. This technique estimates a user’s location based on step detection, step length estimation, and orientation, enabling continuous tracking even in areas with poor signal reception.

3. **Kalman Filter for Sensor Integration**  
   The Kalman filter integrates positioning data from Wi-Fi, cellular signals, and MEMS sensors to enhance accuracy. This statistical algorithm filters noise and combines observations to produce reliable estimates, achieving an average positioning accuracy of 2.41 meters during testing.

### Innovative Floor Plan Integration
Using AutoCAD, I manually created detailed floor plans of the test locations, mapping reference points and test points. These plans were critical for visualizing positioning accuracy and aligning real-world movements with predicted locations.

### Key Results
The research tested the system in two distinct environments:\n
- The International School’s fifth floor  
- The Foreign Student Dormitory’s sixth floor  

Results demonstrated significant improvements in accuracy, particularly in areas with robust Wi-Fi and cellular coverage. The Foreign Student Dormitory, equipped with better signal infrastructure, yielded superior results compared to the International School.

## Implications and Future Work
This work underscores the potential of leveraging existing technologies for cost-effective indoor positioning. The fusion of Wi-Fi, cellular, and MEMS sensors provides a scalable solution adaptable to diverse environments. Future research could explore:\n
- Automating floor plan creation using computer vision.  
- Enhancing robustness in dynamic environments with varying signal conditions.  
- Integrating additional sensors, such as Bluetooth beacons or UWB, for higher precision.  

## Final Thoughts
Indoor positioning systems are crucial in today’s interconnected world, impacting industries like healthcare, retail, and emergency response. By employing innovative techniques and leveraging common smartphone technologies, this research contributes to making accurate indoor localisation more accessible and scalable.

This project reflects my passion for solving real-world challenges with practical, innovative solutions. I look forward to further opportunities to refine and expand upon this work, bridging the gap between research and impactful applications.

