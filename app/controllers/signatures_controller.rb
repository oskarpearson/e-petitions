class SignaturesController < ApplicationController
  before_filter :retrieve_petition, :only => [:new, :create, :thank_you, :signed]
  before_filter :retrieve_signature, :only => [:signed, :verify, :unsubscribe]
  include ActionView::Helpers::NumberHelper

  respond_to :html

  def new
    assign_stage
    @stage_manager = Staged::PetitionSigner.manage(signature_params_for_new, @petition, params[:stage], params[:move])
    respond_with @stage_manager.stage_object
  end

  def create
    matching_signatures = find_existing_pending_signatures
    if matching_signatures.any?
      handle_existing_signatures(matching_signatures, @petition)
    else
      handle_new_signature(@petition)
    end
  end

  def verify
    @petition = @signature.petition

    if @signature.validate_from_token!(params[:token])
      # if signature is that of the petition's creator, mark the petition as validated
      if @signature.creator?
        @petition.state = Petition::VALIDATED_STATE
        @petition.save!

      # if signature is a sponsor, tell the creator about the support
      elsif @signature.sponsor?
        send_sponsor_support_notification_email_to_petition_owner(@petition, @signature)
        @petition.update_sponsored_state
        redirect_to sponsored_petition_sponsor_url(@petition, token: @petition.sponsor_token) and return
      # else signature is from an ordinary or sponsor signee so let's redirect to petition's page
      else
        redirect_to signed_petition_signature_url(@petition, @signature) and return
      end
    else
      # We've found the signature, but it's already been verified.
      if @signature.validated?
        flash[:notice] = "Thank you. Your signature has already been added to the <span class='nowrap'>e-petition</span>."
        redirect_to signed_petition_signature_url(@petition, @signature) and return
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  def unsubscribe
    if @signature.unsubscribe_token != params[:unsubscribe_token]
      render 'signatures/unsubscribe/failed_to_unsubscribe'
    elsif @signature.unsubscribed?
      render 'signatures/unsubscribe/already_unsubscribed'
    else
      @signature.unsubscribe!
      render 'signatures/unsubscribe/successfully_unsubscribed'
    end
  end

  private
  def retrieve_petition
    @petition = Petition.visible.find(params[:petition_id])
  end

  def retrieve_signature
    @signature = Signature.find(params[:id])
  end

  def send_email_to_petition_signer(signature)
    PetitionMailer.email_confirmation_for_signer(signature).deliver_now
  end

  def assign_stage
    return if Staged::PetitionSigner.stages.include? params[:stage]
    params[:stage] = 'signer'
  end

  def signature_params_for_new
    {country: 'United Kingdom'}
  end

  def signature_params_for_create
    @_signature_params_for_create ||=
      params.
        require(:signature).
        permit(:name, :email, :email_confirmation,
               :postcode, :country, :uk_citizenship)
  end

  def send_sponsor_support_notification_email_to_petition_owner(petition, signature)
    petition.notify_creator_about_sponsor_support(petition.sponsors.for(signature))
  end

  def find_existing_pending_signatures
    @signature = Signature.new(signature_params_for_create)
    @signature.email.strip!
    @signature.petition = @petition
    Signature.pending.matching(@signature)
  end

  def handle_existing_signatures(signatures, petition)
    signatures.each { |sig| send_email_to_petition_signer(sig) }
    redirect_to thank_you_petition_signatures_url(petition)
  end

  def handle_new_signature(petition)
    assign_stage
    @stage_manager = Staged::PetitionSigner.manage(signature_params_for_create, petition, params[:stage], params[:move])
    if @stage_manager.create_signature
      send_email_to_petition_signer(@stage_manager.signature)
      respond_with @stage_manager.stage_object, :location => thank_you_petition_signatures_url(petition)
    else
      render :new
    end
  end
end
