#!/bin/env ruby
# encoding: utf-8

class Quiz < ActiveRecord::Base
	# cache_correct_answer e cache_wrong_answer sono variabili di appoggio per registrare risposte 
	# corrette e risposte errate senza dover fare delle query complesse.
	# Il valore deve essere aggiornato alla creazione di ogni
	# user_interaction tenendo conto che per i TRIVIA la risposta non puo' essere modificata.

  	attr_accessible :question, :answers_attributes, :cache_wrong_answer, :cache_correct_answer, :quiz_type, :one_shot
  
  	has_one :interaction, as: :resource
  	has_many :answers, dependent: :destroy

  	accepts_nested_attributes_for :answers

  	validates_presence_of :question, allow_blank: false 
    validate :check_correct_answer_counter, if: Proc.new { |q| q.quiz_type == "TRIVIA" }

    def check_correct_answer_counter
      answer_correct_count = 0
      answers.each { |a| answer_correct_count = answer_correct_count + 1 if a.correct }
      if answers && (answers.where("correct=true").count > 1 || answer_correct_count > 1)
        errors.add("answers", "ogni interaction di tipo quiz può avere al massimo una risposta corretta") 
      elsif answers && (answers.where("correct=true").count < 1 && answer_correct_count < 1) 
        errors.add("answers", "ogni interaction di tipo quiz deve avere almeno una risposta corretta")
      end
    end

  	def quiz_type_enum
      ["TRIVIA", "VERSUS", "PENDING"]
    end
end
