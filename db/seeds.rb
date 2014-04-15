=begin
	p1 = Property.create(name: "Paperino")
	p2 = Property.create(name: "Lupin")

	yt = MediaType.create(name: "Youtube")
	MediaType.create(name: "Nessuno")
	MediaType.create(name: "Immagine")
	MediaType.create(name: "Ooyala")

	#creo le tipologie di periodicità concorso
	PeriodicityType.create(:name => "Giornaliero", :period => 1)
	PeriodicityType.create(:name => "Settimanale", :period => 7)
	PeriodicityType.create(:name => "Mensile", :period => 30)

	# Creo 3 Calltoaction di tipo VERSUS
	cta = Calltoaction.create(title: "TITOLO #v1", activated_at: Time.now, property_id: p1.id, media_type_id: yt.id, video_url: "w2iRxZBygMg")
	q = Quiz.create(question: "Chi preferisci tra...", quiz_type: "VERSUS")
	Interaction.create(name: "#v1", resource: q, calltoaction_id: cta.id, points: 100, when_show_interaction: "OVERVIDEO_DURING", seconds: 3)
	Answer.create(text: "#riposta1", quiz_id: q.id)
	Answer.create(text: "#riposta2", quiz_id: q.id)
	q = Quiz.create(question: "Chi preferisci tra...", quiz_type: "VERSUS")
	Interaction.create(name: "#v3", resource: q, calltoaction_id: cta.id, points: 100, when_show_interaction: "SEMPRE_VISIBILE")
	Answer.create(text: "#riposta1", quiz_id: q.id)
	Answer.create(text: "#riposta2", quiz_id: q.id)
	q = Quiz.new(question: "Chi preferisci tra...", quiz_type: "TRIVIA")
	Interaction.create(name: "#t4", resource: q, calltoaction_id: cta.id, points: 100, added_points: 100, when_show_interaction: "OVERVIDEO_DURING", seconds: 8)
	Answer.create(text: "#riposta1", quiz_id: q.id)
	Answer.create(text: "#riposta2C", quiz_id: q.id, correct: true)
	Answer.create(text: "#riposta3", quiz_id: q.id)
	q.save
	c = Comment.create
	Interaction.create(name: "#c1", resource: c, calltoaction_id: cta.id, when_show_interaction: "SEMPRE_VISIBILE")

	cta = Calltoaction.create(title: "TITOLO #v2", activated_at: Time.now, property_id: p2.id, media_type_id: yt.id, video_url: "w2iRxZBygMg")
	q = Quiz.create(question: "Chi preferisci tra...", quiz_type: "VERSUS")
	Interaction.create(name: "#v2", resource: q, calltoaction_id: cta.id, points: 100, when_show_interaction: "SEMPRE_VISIBILE")
	Answer.create(text: "#riposta1", quiz_id: q.id)
	Answer.create(text: "#riposta2", quiz_id: q.id)
	c = Comment.create
	Interaction.create(name: "#c2", resource: c, calltoaction_id: cta.id, when_show_interaction: "SEMPRE_VISIBILE")

	cta = Calltoaction.create(title: "TITOLO #v3", activated_at: Time.now, property_id: p1.id, media_type_id: yt.id, video_url: "w2iRxZBygMg")
	q = Quiz.create(question: "Chi preferisci tra...", quiz_type: "VERSUS")
	Interaction.create(name: "#v3", resource: q, calltoaction_id: cta.id, points: 100, when_show_interaction: "SEMPRE_VISIBILE")
	Answer.create(text: "#riposta1", quiz_id: q.id)
	Answer.create(text: "#riposta2", quiz_id: q.id)
	c = Comment.create
	Interaction.create(name: "#c3", resource: c, calltoaction_id: cta.id, when_show_interaction: "SEMPRE_VISIBILE")

	# Creo 3 Calltoaction di tipo TRIVIA
	cta = Calltoaction.create(title: "TITOLO #t1", activated_at: Time.now, property_id: p1.id, media_type_id: yt.id, video_url: "w2iRxZBygMg")
	q = Quiz.new(question: "Chi preferisci tra...", quiz_type: "TRIVIA")
	Interaction.create(name: "#t1", resource: q, calltoaction_id: cta.id, points: 100, added_points: 100, when_show_interaction: "SEMPRE_VISIBILE")
	Answer.create(text: "#riposta1", quiz_id: q.id)
	Answer.create(text: "#riposta2C", quiz_id: q.id, correct: true)
	Answer.create(text: "#riposta3", quiz_id: q.id)
	q.save
	c = Comment.create
	Interaction.create(name: "#c3", resource: c, calltoaction_id: cta.id, when_show_interaction: "SEMPRE_VISIBILE")

	cta = Calltoaction.create(title: "TITOLO #t2", activated_at: Time.now, property_id: p2.id, media_type_id: yt.id, video_url: "w2iRxZBygMg")
	q = Quiz.new(question: "Chi preferisci tra...", quiz_type: "TRIVIA")
	Interaction.create(name: "#t2", resource: q, calltoaction_id: cta.id, points: 100, added_points: 100, when_show_interaction: "SEMPRE_VISIBILE")
	Answer.create(text: "#riposta1", quiz_id: q.id)
	Answer.create(text: "#riposta2C", quiz_id: q.id, correct: true)
	Answer.create(text: "#riposta3", quiz_id: q.id)
	q.save
	c = Comment.create
	Interaction.create(name: "#c4", resource: c, calltoaction_id: cta.id, when_show_interaction: "SEMPRE_VISIBILE")

	cta = Calltoaction.create(title: "TITOLO #t3", activated_at: Time.now, property_id: p1.id, media_type_id: yt.id, video_url: "w2iRxZBygMg")
	q = Quiz.new(question: "Chi preferisci tra...", quiz_type: "TRIVIA")
	Interaction.create(name: "#t3", resource: q, calltoaction_id: cta.id, points: 100, added_points: 100, when_show_interaction: "SEMPRE_VISIBILE")
	Answer.create(text: "#riposta1", quiz_id: q.id)
	Answer.create(text: "#riposta2", quiz_id: q.id)
	Answer.create(text: "#riposta3C", quiz_id: q.id, correct: true)
	q.save
	c = Comment.create
	Interaction.create(name: "#c5", resource: c, calltoaction_id: cta.id, when_show_interaction: "SEMPRE_VISIBILE")
=end