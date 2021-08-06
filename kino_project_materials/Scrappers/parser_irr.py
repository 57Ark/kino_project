from bs4 import BeautifulSoup
from requests import get
import time
import random
import csv

houses = []

with open('irr.csv', 'w') as csvfile:
	
	count = 1
	while count <= 5:
		try:
			url = 'https://irr.ru/real-estate/rent/search/rent_period=3915714150/page' + str(count)
			
			try:
				response = get(url)
			except Exception as exc:
				print('Error: ', exc)

			html_soup = BeautifulSoup(response.text, 'html.parser')

			house_data = html_soup.find('div', class_='js-listingContainer').findAll('div', class_='listing__item js-productBlock')

			if house_data != []:
				houses.extend(house_data)
				value = random.random()
				scaled_value = 1 + (value * (9 - 5))
				time.sleep(scaled_value)
			else:
				break
			count += 1
		except Exception as exc:
			break


	fieldnames = ['title', 'address', 'price', 'floor', 'overall floor', 'rooms', 'square', 'images', 'link']
	writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
	writer.writeheader()

	n = int(len(houses)) - 1
	count = 0
	while count <= n:
		try:
			title = address = price = overall_floor = rooms = floor = square = link = ''		
		
			info = houses[int(count)]
			
			link = info.get('data-href')
			response = get(link)
			html_soup = BeautifulSoup(response.text, 'html.parser')
			
			# IMAGES
			images = []
			for img in html_soup.find('div', class_='lineGallery js-lineProductGallery').findAll('img'):
				images.append(img.get('data-src'))
			
			# INFO
			
			square = info.find('div', class_='listing__itemColumn listing__itemColumn_param1').text

			if square[-2] == 'м' and square[-1] == '2':
				square = square[:-3]
			else:
				square = ''

			info_floors = info.find('div', class_='listing__itemColumn listing__itemColumn_param2').text[4:]
			sl = info_floors.find('/')
			if sl != -1:
				floor = info_floors[:(sl-1)]
				overall_floor = info_floors[(sl+1):]

			price = html_soup.find('div', class_='productPage__price').text.strip()
			price = price[:-14]
			
			details = html_soup.find('div', class_='productPage js-productPageDescriptions')
			
			title = html_soup.find('h1', class_='productPage__title js-productPageTitle').text.strip()
			title = title.replace(',', '')
			
			info = details.find('div', class_='productPage__characteristicsBlock js-productPage__characteristicsBlock').findAll('span', class_='productPage__characteristicsItemValue')
			
			rooms = info[0].text
			if len(rooms) != 1:
				rooms = ''

			address = html_soup.find('div', class_='productPage__infoTextBold js-scrollToMap').text.strip()
			address = address.replace(',', '')
			
			csv_table = {'title':title, 'address':address, 'price':price, 'rooms':rooms, 'floor':floor, 'overall floor':overall_floor,'square':square, 'images':images, 'link':link}
			
			writer.writerow(csv_table)
			
		except Exception as exc:
			pass
			
		count += 1
