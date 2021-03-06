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
  Serial.begin(115200);
  Wire.begin();
  RTC.begin();
  ioinit();
  LCDInit();
  LCDContrast(44);
  LCDClear(WHITE);
 
  initValues(); 
}

void initValues() {
  
  maxTemperature = minTemperature = sht1x.readTemperatureC();
  maxHumidity = minHumidity = sht1x.readHumidity();
}

int liveShow = 0;

void loop()
{
  int	s1, s2, s3;
	s1	=	!digitalRead(kSwitch1_PIN);
	s2	=	!digitalRead(kSwitch2_PIN);
	s3	=	!digitalRead(kSwitch3_PIN);   
  if (s1) {
    LCDPutStr("R", 0, 100, YELLOW, WHITE); 
    initValues();
    LCDPutStr(" ", 0, 100, WHITE, WHITE); 
  }

  printTime();
  
  printTemperatureAndHumidity();

  liveShow++;
  liveShow %= 4;
  char* state;
  switch (liveShow) {
    case 0:  state = "| ";
      break;
    case 1:  state = "/ ";
      break;    
    case 2:  state = "- ";
      break;    
    case 3:  state = "\\ ";
      break;
  }
  LCDPutStr(state, 0, 110, BLACK, WHITE);   

  //delay(100);
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
  
void printTemperatureAndHumidity() 
{
  float temperatureInCels = sht1x.readTemperatureC();
  float humidity = sht1x.readHumidity();  
  
  updateMinMaxGlobalState(temperatureInCels, humidity);
  
  updateDisplay(temperatureInCels, humidity);
}

void updateMinMaxGlobalState(float curTemperature, float curHumidity)
{
  if (curTemperature > maxTemperature) {
    maxTemperature = curTemperature;
  }
  if (curTemperature < minTemperature) {
    minTemperature = curTemperature;
  }
  
  if (curHumidity > maxHumidity) {
    maxHumidity = curHumidity;
  }
  if (curHumidity < minHumidity) {
    minHumidity = curHumidity;
  }
}

void updateDisplay(float curTemperature, float curHumidity)
{
  char buffer[20];
  
  dtostrf(curTemperature, 2, 1, buffer);
  LCDPutStr(buffer, 30, 10, BLUE, WHITE);
  LCDPutStr("C", 30, 48, BLUE, WHITE);

  formatRange(minTemperature, maxTemperature, buffer);
  LCDPutStr(buffer, 50, 10, RED, WHITE);  
  
  dtostrf(curHumidity, 2, 1 , buffer);
  LCDPutStr(buffer, 80, 10, BLUE, WHITE);  
  LCDPutStr("%", 80, 45, BLUE, WHITE);
  
  formatRange(minHumidity, maxHumidity, buffer);
  LCDPutStr(buffer, 100, 10, RED, WHITE);  
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

