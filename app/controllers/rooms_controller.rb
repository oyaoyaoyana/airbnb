class RoomsController < ApplicationController
before_action :set_room, except: [:index, :new, :create]
before_action :authenticate_user!, except: [:show]
before_action :is_authorised, only: [:listing, :pricing, :description, :photo_upload, :amenities, :location, :update]

  def index
    @rooms = current_user.rooms
  end

  def show
    @photos = @room.photos
    @guest_reviews = @room.guest_reviews
  end

  def new
    @room = current_user.rooms.build
  end

  def create
    @room = current_user.rooms.build(room_params)
    if @room.save
      redirect_to listing_room_path(@room), notice: "Saved.."
    else
      flash[:alert] = "Something went wrong..."
    end
  end

  def edit
    if current_user.id == @room.user.id
      @photos = @room.photos
    else
      redirect_to root_path, notice: "You don't have permission."
    end
  end

  def update
    new_params = room_params
    new_params = room_params.merge(active: true) if is_ready_room

    if @room.update(new_params)
      flash[:notice] = "Saved..."
    else
      flash[:alert] = "Something went wrong..."
    end
    redirect_back(fallback_location: request.referer)
  end


  def destroy
  end
  
  def preload
    today = Date.today
    reservations = @room.reservations.where("(start_date >= ? OR end_date >= ?) AND status = ?", today, today, 1)

    render json: reservations
  end

  def preview
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    output = {
      conflict: is_conflict(start_date, end_date, @room)
    }

    render json: output
  end

  def photo_upload
    @photos = @room.photos
  end
  
  def listing
  end

  def pricing
  end

  def description
  end


  def amenities
  end

  def location
  end

  private
    def set_room
      @room = Room.find(params[:id])
    end
    def room_params
      params.require(:room).permit(:home_type, :room_type, :accommodate, :bed_room, :bath_room, :listing_name, :summary, :address, :is_tv, :is_kitchen, :is_air, :is_heating, :is_internet, :price, :active, :instant)
    end

    def is_conflict(start_date, end_date, room)
      check = room.reservations.where("? < start_date AND end_date < ?", start_date, end_date)
      check.size > 0? true : false
    end

    def is_authorised
      redirect_to root_path, alert: "You don't have permission" unless current_user.id == @room.user_id
    end

    def is_ready_room
      !@room.active && !@room.price.blank? && !@room.listing_name.blank? && !@room.photos.blank? && !@room.address.blank?
    end
end
