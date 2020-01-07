class MiniEventCustomersController < ApplicationController
  # before_action :authenticate_any!, :new
  before_action :authenticate_student!, :new
  def new
    @mini_event_customer = MiniEventCustomer.new
    @mini_event = MiniEvent.find(params[:mini_event_id])
  end

  def create
    @mini_event = MiniEvent.find(params[:mini_event_id])
    student = current_student
    @mini_event_customer = MiniEventCustomer.new

    @mini_event_customer.mini_event_id = params[:mini_event_id]
    @mini_event_customer.student_id = student.id
    @mini_event_customer.school_id = student.school.id
    @mini_event_customer.email = student.email
    @mini_event_customer.name = student.first_name + student.last_name



    mini_event_id = @mini_event_customer.mini_event.id
    if @mini_event_customer.mini_event.pay_point.nil?
      @mini_event_customer.mini_event.pay_point = 0
      @mini_event_customer.mini_event.save
    end

    pay_way = params[:pay_way]

    if student_signed_in?
      @mini_event_customer.student_id = current_student.id
      @mini_event_customer.check = false
      if current_student.point.nil?
        point = create_new_point(current_student)
      else
        point = current_student.point
      end
      if params[:pay_way] == "point"
        if point.having_point >= @mini_event_customer.mini_event.pay_point
          current_student.point.having_point = point.having_point - @mini_event_customer.mini_event.pay_point
          current_student.point.save
          MiniEventApplyTag.create(
            mini_event_id: mini_event_id,
            student_id: current_student.id,
            has_paid: true,
            pay_point: true,
            pay_cash: false
          )
          if @mini_event_customer.save
            NotificationMailer.mini_event_send_confirm_to(@mini_event_customer).deliver
            redirect_to root_path
          else
            redirect_to root_path
          end
        else
          # ポイントが達してない場合
          redirect_to new_mini_event_mini_event_customer_path(mini_event_id: params[:mini_event_id])
          flash[:alarm] = "ポイントが足りません、現金でお支払いを選択してください。"
        end
      elsif params[:pay_way] == "cash" || params[:pay_way].nil?
          MiniEventApplyTag.create(
            mini_event_id: mini_event_id,
            student_id: current_student.id,
            has_paid: false,
            pay_point: false,
            pay_cash: false
          )
        if @mini_event_customer.save
          NotificationMailer.mini_event_send_confirm_to(@mini_event_customer).deliver
          redirect_to home_all_event_apply_complete_path
        else
          redirect_to root_path
        end
      end
    end
  end

  def edit
  end

  def update
  end

  def destroy
    @mini_event_customer = MiniEventCustomer.find(params[:id])
    @mini_event_customer.delete
    if student_signed_in?
      redirect_to student_page_path(current_student.id)
    else
      redirect_to root_path
    end
  end

  private

  def mini_event_customer_params
      params.require(:mini_event_customer)
      .permit(
        :mini_event_id,
        :student_id,
        :school_id,
        :name,
        :email,
        :phone_num
        )
  end
  
end
