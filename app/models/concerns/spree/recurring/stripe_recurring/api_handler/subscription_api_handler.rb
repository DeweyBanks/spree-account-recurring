module Spree
  class Recurring < Spree::Base
    class StripeRecurring < Spree::Recurring
      module ApiHandler
        module SubscriptionApiHandler
          def subscribe(subscription)
            raise_invalid_object_error(subscription, Spree::Subscription)
            customer = subscription.user.find_or_create_stripe_customer(subscription.card_token)
            stripe_subscription = customer.subscriptions.create(plan: subscription.api_plan_id, trial_end:subscription.trial_end)
            subscription.stripe_id = stripe_subscription.id
            #TODO: merge second stripe call into first, the combined call works in test and pry, but not in live code
            stripe_subscription.quantity = subscription.quantity            
            stripe_subscription.tax_percent = subscription.tax_percent
            stripe_subscription.save
          end

          def unsubscribe(subscription)
            raise_invalid_object_error(subscription, Spree::Subscription)
            subscription.user.api_customer.cancel_subscription
          end
        end
      end
    end
  end
end
