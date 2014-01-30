//
//  CoreLocationExtension.m
//  BusAppCoreData
//
//  Created by Renan Camargo de Castro on 30/01/14.
//  Copyright (c) 2014 BEPiD. All rights reserved.
//

#import "CoreLocationExtension.h"


@implementation CoreLocationExtension



/** Function that receives a location, a distance, and a angle and returns a new geopoint. It's calculated with
 the Vincenty formula's.
 @param startingPoint Point from wich we have to calculate the distance.
 @param distanceInMeters distance in meters.
 @param bearingInDegrees 0->360, 0-> N, 90->E, 180->S, 270->W.
 @return CLLocationCoordinate2D point that is "distanceInMeters" away from startingPoint.
 */
+ (CLLocationCoordinate2D) NewLocationFrom:(CLLocationCoordinate2D)startingPoint
						atDistanceInMeters:(float)distanceInMeters
                     alongBearingInDegrees:(double)bearingInDegrees {
	
    double lat1 = DegreesToRadians(startingPoint.latitude);
    double lon1 = DegreesToRadians(startingPoint.longitude);
	
    double a = 6378137, b = 6356752.3142, f = 1/298.257223563;  // WGS-84 ellipsiod
	double s = distanceInMeters;
    double alpha1 = DegreesToRadians(bearingInDegrees);
    double sinAlpha1 = sin(alpha1);
    double cosAlpha1 = cos(alpha1);
	
    double tanU1 = (1 - f) * tan(lat1);
    double cosU1 = 1 / sqrt((1 + tanU1 * tanU1));
    double sinU1 = tanU1 * cosU1;
    double sigma1 = atan2(tanU1, cosAlpha1);
    double sinAlpha = cosU1 * sinAlpha1;
    double cosSqAlpha = 1 - sinAlpha * sinAlpha;
    double uSq = cosSqAlpha * (a * a - b * b) / (b * b);
    double A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    double B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
	
    double sigma = s / (b * A);
    double sigmaP = 2 * M_PI;
	
    double cos2SigmaM;
    double sinSigma;
    double cosSigma;
	
    while (abs(sigma - sigmaP) > 1e-12) {
        cos2SigmaM = cos(2 * sigma1 + sigma);
        sinSigma = sin(sigma);
        cosSigma = cos(sigma);
        double deltaSigma = B * sinSigma * (cos2SigmaM + B / 4 * (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) - B / 6 * cos2SigmaM * (-3 + 4 * sinSigma * sinSigma) * (-3 + 4 * cos2SigmaM * cos2SigmaM)));
        sigmaP = sigma;
        sigma = s / (b * A) + deltaSigma;
    }
	
    double tmp = sinU1 * sinSigma - cosU1 * cosSigma * cosAlpha1;
    double lat2 = atan2(sinU1 * cosSigma + cosU1 * sinSigma * cosAlpha1, (1 - f) * sqrt(sinAlpha * sinAlpha + tmp * tmp));
    double lambda = atan2(sinSigma * sinAlpha1, cosU1 * cosSigma - sinU1 * sinSigma * cosAlpha1);
    double C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
    double L = lambda - (1 - C) * f * sinAlpha * (sigma + C * sinSigma * (cos2SigmaM + C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)));
	
    double lon2 = lon1 + L;
	
    // Create a new CLLocationCoordinate2D for this point
    CLLocationCoordinate2D edgePoint = CLLocationCoordinate2DMake(RadiansToDegrees(lat2), RadiansToDegrees(lon2));
	
    return edgePoint;
}


//- (CLLocationCoordinate2D) NewLocationFrom:(CLLocationCoordinate2D)startingPoint
//						atDistanceInMeters:(float)distanceInMeters
//                     alongBearingInDegrees:(double)bearingInDegrees {
//
//	double LatDistance = cos(bearingInDegrees)*distanceInMeters;
//	double LongDistance = sin(bearingInDegrees)*distanceInMeters;
//
//	CLLocationCoordinate2D destinationPoint = CLLocationCoordinate2DMake(startingPoint.latitude + (LatDistance*0.00001), startingPoint.longitude + (LongDistance*0.00001));
//
//	return destinationPoint;
//}

@end
