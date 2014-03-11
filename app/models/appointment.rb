class Appointment < ActiveRecord::Base
  validate :appointment_time
  
  # appointment time can not overlap with other appointments
  # and must start before it ends
  def  appointment_time
    rec = self
    cond = {:start_time => self.start_time, 
            :end_time => self.end_time,
            :id => self.id
            }
    if self.start_time > self.end_time
      errors.add(:appointment_invalid, "start time must be before end time")
    else
      # check for appointment overlap with other appointments
      cond_str = '(start_time >= :start_time and start_time <= :end_time) or ' +
         '(start_time <= :start_time and end_time >= :start_time) or ' +
         '(start_time <= :start_time and end_time >= :start_time)'
      cond_str = "id <> :id and (#{cond_str})" if self.id   
         
      overlap_recs = self.class.where(
        [cond_str, cond])            
      if overlap_recs.size > 0      
        errors.add(:appointment_overlap, "can not schedule")
      end
    end           
  end
  
end
