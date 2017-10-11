#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
Created on Wed Jun 29 20:12:23 2016

@author: Sina AHMADI
"""

class Scraping:
	"""
	This class is aimed to scrape the data in order to construct the corpora using
	the produced query for each question and response.
	"""

	def __init__(self, questionnaire, reponses, category):
		self.questionnaire = questionnaire
		self.reponses = reponses
		self.category = category

		self.LOG_FILENAME = "log_files/corpus_creation.log"
		self.link_directory = "corpus/raw/links"
		self.stop_word_directory = "resource/stopwords_fr.txt"
		# Creation of the needed directories.
		if not os.path.exists("corpus"):
		    os.makedirs("corpus")
		if not os.path.exists("corpus/raw"):
		    os.makedirs("corpus/raw")

	def starter(self):
		logging.basicConfig(filename = self.LOG_FILENAME, level = logging.DEBUG)

		choice_number = 0
		for i in range(len(self.reponses)):
			choice_number = choice_number + len(self.reponses[i])

		if(not os.path.exists(self.link_directory)):
			os.mkdir(self.link_directory)

		# creating the search key
		stopwords_file = codecs.open(self.stop_word_directory, "r", "utf-8").read()
		stopwords_list = stopwords_file.split("\n")
		cat = category.split()

		time_counter = 0
		for question_index in range(len(self.questionnaire)):
			question = self.questionnaire[question_index]
			for choice_index in range(len(self.reponses[question_index])):
				search_key = ""
				choice = self.reponses[question_index][choice_index]
				search_key = ("".join(question) + " " + choice).split()
				search_key = self.refiner(search_key, stopwords_file)
				for c in cat:
					if(c not in search_key):
						search_key |= {c}
				search_key = "\"" + " ".join(search_key) + "\""
				search_key = (' '.join(search_key.split())).lower()

				argv0 = search_key
				argv1 = 3 # 3 pages
				argv2 = ("\"" + category + " " + str(question_index+7) + " " +  str(choice_index) + "\"").replace(" ", "_")
				arguments = " " + argv0 + " " + str(argv1) + " " + argv2

				# print(argv0)
				print("\tEvoking the corpus scraper...")
				print("\tArguments: %s"%arguments)
				print("\tTime needed: %d seconds"%( (10*(choice_number- time_counter))))
				command = "perl scraping.pl"+ arguments
				os.system(command)
				# --------------------------- logging
				logging.debug("\tEvoking the corpus scraper...")
				logging.debug("\tArguments: %s"%arguments)
				logging.debug("\tTime needed: %d seconds"%( (10*(choice_number- time_counter))))

				time_counter = time_counter+1
				print("\t Links collected.")
				print("\t-------------------------------------------------")
				print("\tCat : %s, Question : %d, Choice : %d "%(category, question_index+1, choice_index+1))
				print("\t-------------------------------------------------")

				# --------------------------- logging
				logging.debug("\t-------------------------------------------------")
				logging.debug("\tCat : %s, Question : %d, Choice : %d "%(category, question_index+1, choice_index+1))
				logging.debug("\t-------------------------------------------------")

				# Reading links and scraping their content.
				fichier = self.link_directory + "/" + argv2.replace("\"", "") + ".txt"
				input_file = codecs.open(fichier, "r", "utf-8")
				input_text = (input_file.read()).split("\n")
				input_file.close()
				fichier_name = fichier.split("/")[-1]
				output_file = codecs.open("corpus/raw/"+fichier_name, "a", "utf-8")

				print("Processing %s"%fichier_name )
				for line in input_text:
					if(line != "\n" and "----------------------" not in line):
						print("\t"+line)
						try:
						    output_file.write(self.content_scraper(line))
						except:
							print("\t-------------------------------")
							print("\t\tUnknown Error")
							print("\t-------------------------------")
				output_file.close()

	def refiner(self, search_key, stopwords_list):
		"""
		Refines the queries by eliminating the words that exist in the stop word list.
		Punctuiation marks are also considered.
		"""
		valid_set = set()
		for search_key_index in range(len(search_key)):
		 for c in string.punctuation:
		     search_key[search_key_index] = search_key[search_key_index].replace(c, " ")
		     for n in string.digits:
		         search_key[search_key_index] = search_key[search_key_index].replace(n, "")
		         if(len(search_key[search_key_index])>1 and search_key[search_key_index] not in stopwords_list and search_key[search_key_index] not in valid_set):
		             valid_set |= {search_key[search_key_index]}
		return valid_set

	def content_scraper(self, url):
		"""
		Gets a URL and returns its content using BeautifulSoupa (no HTML tag or Javascript code)
		"""
		# socks.setdefaultproxy(socks.PROXY_TYPE_SOCKS4, "127.0.0.1", 9050, True)
		# socket.socket = socks.socksocket

		html = urllib.urlopen(url).read()
		soup = BeautifulSoup(html, "lxml")
		# kill all script and style elements
		for script in soup(["script", "style"]):
			script.extract()
		# get text
		text = soup.get_text()
		# break into lines and remove leading and trailing space on each
		lines = (line.strip() for line in text.splitlines())
		# break multi-headlines into a line each
		chunks = (phrase.strip() for line in lines for phrase in line.split("  "))
		# drop blank lines
		text = '\n'.join(chunk for chunk in chunks if chunk)
		return text
