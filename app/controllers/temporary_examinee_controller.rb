class TemporaryExamineeController < ApplicationController
    
    require 'active_support/secure_random'
    require 'csv'
    filter_access_to :all
    
  def new
    @user = User.new
  end

  def create
    @outfile = t('user.temp_examinee')+ '-' + Time.now.strftime("%m-%d-%Y-%H-%M-%S") + ".csv"
    @infile = ""

    @count = params[:count].to_i
    @login = SecureRandom.hex(1)
    @i = 1
    @password_array = []
    until @i > @count
    @pwd = SecureRandom.hex(5)
    @password_array << @pwd
    @i +=1
    end
              
    @first_login = @login
    @login_count = 1

    report = StringIO.new
    csv_data=CSV::Writer.generate(@infile) do |csv|

      csv << [t('reports.s_no'),t('login.userid'),t('login.password')]

      @password_array.each do |password|
      
      csv << [
      @login_count,
      @login+@login_count.to_s+'d'+Time.now.strftime("%Y%m%d")+'t'+Time.now.strftime("H%M%S"),
      password    ]

      @user = User.new(:login=>@first_login+@login_count.to_s+'d'+Time.now.strftime("%Y%m%d")+'t'+Time.now.strftime("H%M%S"),:email=>@login_count.to_s+Time.now.strftime("%Y%m%d%H%M%S"),:password=>password, :role_id=>4,:confirmed=>true, :is_approved=>1, :is_temp_examinee=>1, :active=> 1)
      @user.save(false)
      @login_count +=1

    end
   end
    @current_user = current_user
    UserMailer.export_csv(@outfile, @infile, @current_user).deliver

    flash[:success] = "#{@login_count - 1} #{t('flash_success.temp_examinee_created')}"
    redirect_to :back
  end
 end