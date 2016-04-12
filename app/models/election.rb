class Election < ActiveRecord::Base
  belongs_to :organisation

  has_many :candidate_elections
  has_many :candidates, through: :candidate_elections

  has_many :votes

  scope :expired, -> { where("end_date < ?", Time.now) }
  scope :active, -> { where("end_date > ?", Time.now) }

  # Active record hooks
  before_create :set_defaults

  def set_defaults
    self.created_at = Time.now
  end

  def add_candidates(candidate_ids)
    organisation.candidates.where(id: candidate_ids).each do |c|
      add_candidate(c)
    end
  end

  def add_candidate(candidate)
    CandidateElection.create({candidate_id: candidate.id, election_id: self.id})
  end

  def remove_candidate(candidate)
    CandidateElection.where({candidate_id: candidate.id, election_id: self.id}).delete_all
  end

  def finished?
    end_date < Time.now
  end
end
