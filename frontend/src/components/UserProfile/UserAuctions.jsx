import React, { useEffect, useState } from 'react';
import axios from 'axios';
import AuctionCard from '../ListAuction/AuctionCard';
import { useSelector } from 'react-redux';
import { Card } from '../ui/card';
const UserAuctions = () => {
  const [auctions, setAuctions] = useState([]);
  const [isLoading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const address = useSelector((state) => state.address.address);
  useEffect(() => {
    const fetchDetails = async () => {
      try {
        setLoading(true);
        const response = await axios.get(`/auctions/user-auctions/${address}`);
        setAuctions(response.data);
      } catch (error) {
        setError(error.message);
        console.error(error);
      } finally {
        setLoading(false);
      }
    };
    fetchDetails();
  }, [address]);
  if (!auctions || auctions.length === 0) {
    return (
      <Card>
        <h1>No Auctions Found</h1>
      </Card>
    );
  }
  if (isLoading) return <div>Loading ......</div>;
  if (error) return <div>Error: {error}</div>;
  return (
    <div className="w-full grid grid-cols-3 gap-5">
      {auctions.map((auction, index) => (
        <AuctionCard auction={auction} key={index} />
      ))}
    </div>
  );
};

export default UserAuctions;
