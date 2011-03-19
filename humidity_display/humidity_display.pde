#include <Wire.h>

#include <LCD_driver.h>
#include <RTClib.h>
#include <SHT1x.h>

#include<stdlib.h>


#define dataPin  12
#define clockPin 13
SHT1x sht1x(dataPin, clockPin);

RTC_DS1307 RTC;

float maxTemperature;
float minTemperature;

float maxHumidity;
float minHumidity;

void setup() 
{
  Serial.begin(57600);
  Wire.begin();
  RTC.begin();
  ioinit();
  LCDInit();
  LCDContrast(44);
  LCDClear(WHITE);
  
  maxTemperature = minTemperature = sht1x.readTemperatureC();
  maxHumidity = minHumidity = sht1x.readHumidity();
}

void loop()
{
  printTime();
  
  printHumidity();

  delay(500);
}

void printTime() 
{
  char dateBuffer[9];
  
  DateTime now = RTC.now();  
  uint8_t hour = now.hour();
  dateBuffer[0] = hour / 10 + '0';
  dateBuffer[1] = hour % 10 + '0'; 
  
  dateBuffer[2] = ':';
  
  uint8_t minute = now.minute();

  dateBuffer[3] = minute / 10 + '0';
  dateBuffer[4] = minute % 10 + '0'; 
  
  dateBuffer[5] = ':';
  
  uint8_t second = now.second();

  dateBuffer[6] = second / 10 + '0';
  dateBuffer[7] = second % 10 + '0'; 
  
  dateBuffer[8] = '\0';
  
  LCDPutStr(dateBuffer, 0, 0, BLACK, RED);    
}
  
void printHumidity() 
{
  float tempCels = sht1x.readTemperatureC();
  float humidity = sht1x.readHumidity();  
  
  if (tempCels > maxTemperature) {
    maxTemperature = tempCels;
  }
  if (tempCels < minTemperature) {
    minTemperature = tempCels;
  }
  
  if (humidity > maxHumidity) {
    maxHumidity = humidity;
  }
  if (humidity < minHumidity) {
    minHumidity = humidity;
  }
  
  char buffer[20];
  dtostrf(tempCels, 2, 1 , buffer);
  LCDPutStr(buffer, 30, 10, BLUE, YELLOW);

  char str[20];
  str[0] = '\0';
  strcat(str, "(");
  //LCDPutStr("(", 50, 10, RED, YELLOW);  
  dtostrf(minTemperature, 2, 1 , buffer);
  strcat(str, buffer);
  //LCDPutStr(buffer, 50, 17, BLUE, YELLOW);
  //LCDPutStr(" - ", 50, 50, BLUE, YELLOW);
  strcat(str, " - ");
  dtostrf(maxTemperature, 2, 1 , buffer);
  strcat(str, buffer);
  //LCDPutStr(buffer, 50, 75, BLUE, YELLOW);
  //LCDPutStr(")", 50, 110, RED, YELLOW);    
  strcat(str, ")");
  LCDPutStr(str, 50, 10, RED, YELLOW);    
  
  dtostrf(humidity, 2, 1 , buffer);
  LCDPutStr(buffer, 80, 10, GREEN, ORANGE);  
  
  LCDPutStr("(", 100, 10, RED, YELLOW);  
  dtostrf(minHumidity, 2, 1 , buffer);
  LCDPutStr(buffer, 100, 17, BLUE, YELLOW);
  LCDPutStr(" - ", 100, 50, BLUE, YELLOW);
  dtostrf(maxHumidity, 2, 1 , buffer);
  LCDPutStr(buffer, 100, 75, BLUE, YELLOW);
  LCDPutStr(")", 100, 110, RED, YELLOW);    
}

void formatRange(float lowValue, float highValue, char* buffer)
{
  buffer[0] = '\0';
  strcat(buffer, "(");
  dtostrf(lowValue, 2, 1 , buffer + strlen(buffer));
  strcat(buffer, " - ");
  dtostrf(highValue, 2, 1 , buffer + strlen(buffer));
  strcat(buffer, ")");
}

