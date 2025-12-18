export default function PricingPage() {
  return (
    <main className="max-w-3xl mx-auto p-6">
      <h1 className="text-2xl font-semibold">Pricing</h1>

      <section className="mt-6">
        <h2 className="text-xl font-medium">Free Plan</h2>
        <ul className="mt-2 list-disc pl-6 text-gray-700">
          <li>Offline daily journaling</li>
          <li>Basic emotion and category detection</li>
          <li>Daily insights</li>
          <li>Local-only data storage</li>
        </ul>
        <p className="mt-2 font-medium">Price: ₹0</p>
      </section>

      <section className="mt-8">
        <h2 className="text-xl font-medium">Premium Plan</h2>
        <ul className="mt-2 list-disc pl-6 text-gray-700">
          <li>Unlimited journal updates</li>
          <li>Weekly and monthly insights</li>
          <li>Advanced emotional trends</li>
          <li>Referral rewards eligibility</li>
        </ul>
        <p className="mt-2 font-medium">
          Price: ₹149 per month or ₹999 per year
        </p>
      </section>

      <p className="mt-6 text-sm text-gray-600">
        Pricing shown is introductory and may change in the future.
      </p>
    </main>
  );
}
